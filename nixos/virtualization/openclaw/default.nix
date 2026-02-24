{ config, pkgs, lib, ... }:

let
  cfg = config.services.openclawGateway;

  containerGatewayPort = 18789;

  configDir = "${cfg.stateDir}/config";
  workspaceDir = "${cfg.stateDir}/workspace";
  skillsDir = "/opt/openclaw-skills";
  envFile = "${configDir}/.env";
  configFile = "${configDir}/openclaw.json";

  composeDir = "/home/esc2/repos/nixos/nixos/virtualization/openclaw";
in
{
  options.services.openclawGateway = {
    enable = lib.mkEnableOption "OpenClaw gateway managed via podman-compose";

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/openclaw";
      description = "Host directory for OpenClaw config/workspace state.";
    };

    userUid = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = "UID used by the container user for mounted state directories.";
    };

    userGid = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = "GID used by the container user for mounted state directories.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir}  0750 ${toString cfg.userUid} ${toString cfg.userGid} -"
      "d ${configDir}     0750 ${toString cfg.userUid} ${toString cfg.userGid} -"
      "d ${workspaceDir}  0750 ${toString cfg.userUid} ${toString cfg.userGid} -"
      "d ${skillsDir}     0755 root root -"
    ];

    system.activationScripts.openclawGatewayBootstrap = ''
      set -eu

      ${pkgs.coreutils}/bin/mkdir -p "${configDir}" "${workspaceDir}"
      ${pkgs.coreutils}/bin/chown ${toString cfg.userUid}:${toString cfg.userGid} "${configDir}" "${workspaceDir}"
      ${pkgs.coreutils}/bin/chmod 0750 "${configDir}" "${workspaceDir}"

      if [ ! -e "${configFile}" ]; then
        ${pkgs.coreutils}/bin/cat > "${configFile}" <<'EOF'
{
  "gateway": { "mode": "local" },
  "agents": {
    "defaults": {
      "model": { "primary": "openai/gpt-4.1" }
    }
  },
  "skills": {
    "entries": {
      "gog-calendar": { "enabled": false }
    }
  }
}
EOF
      fi
      ${pkgs.coreutils}/bin/chown ${toString cfg.userUid}:${toString cfg.userGid} "${configFile}"
      ${pkgs.coreutils}/bin/chmod 0600 "${configFile}"

      # Populate workspace from repo template if missing (unified workspace: no per-file mounts)
      repo_workspace="${composeDir}/workspace"
      if [ -d "$repo_workspace" ]; then
        for f in "$repo_workspace"/*; do
          [ -e "$f" ] || continue
          dest="${workspaceDir}/$(${pkgs.coreutils}/bin/basename "$f")"
          [ -e "$dest" ] || ${pkgs.coreutils}/bin/cp "$f" "$dest"
        done
        ${pkgs.coreutils}/bin/chown -R ${toString cfg.userUid}:${toString cfg.userGid} "${workspaceDir}"
      fi

      if [ ! -e "${envFile}" ]; then
        umask 077
        token="$(${pkgs.openssl}/bin/openssl rand -hex 32)"
        ${pkgs.coreutils}/bin/printf "OPENCLAW_GATEWAY_TOKEN=%s\n" "$token" > "${envFile}"
      fi
      # 0640 so root (podman-compose) and the container user (uid 1000) can both read it
      ${pkgs.coreutils}/bin/chown ${toString cfg.userUid}:root "${envFile}"
      ${pkgs.coreutils}/bin/chmod 0640 "${envFile}"
    '';

    systemd.services.openclaw-gateway = {
      description = "OpenClaw gateway (podman-compose)";
      after = [ "network-online.target" "podman.socket" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "10s";
        TimeoutStartSec = "30min";

        ExecStartPre = [
          # Inject secrets from external files into the runtime env file
          (toString (pkgs.writeShellScript "openclaw-inject-secrets" ''
            set -eu
            dest="${envFile}"

            inject_var() {
              local var="$1" src="$2"
              [ -f "$src" ] || return 0
              local val
              val="$(${pkgs.gnugrep}/bin/grep -m1 "^$var=" "$src" | ${pkgs.coreutils}/bin/cut -d= -f2-)"
              [ -n "$val" ] || return 0
              ${pkgs.gnugrep}/bin/grep -v "^$var=" "$dest" > "$dest.tmp" || true
              # Quote value so python-dotenv handles special characters correctly
              ${pkgs.coreutils}/bin/printf "%s='%s'\n" "$var" "$val" >> "$dest.tmp"
              ${pkgs.coreutils}/bin/mv "$dest.tmp" "$dest"
              ${pkgs.coreutils}/bin/chmod 0640 "$dest"
            }

            inject_var OPENAI_API_KEY     "/home/esc2/repos/nixos/.env"
            inject_var GOG_KEYRING_PASSWORD "/home/esc2/.secrets/openclaw/openclaw.env"
          ''))
          # Build local image and populate skills dir from the image
          (toString (pkgs.writeShellScript "openclaw-build-and-sync-skills" ''
            set -eu
            ${pkgs.podman}/bin/podman build \
              --tag localhost/openclaw-local:latest \
              "${composeDir}"

            # Copy baked skills out of the image into the host skills dir
            cid="$(${pkgs.podman}/bin/podman create localhost/openclaw-local:latest)"
            ${pkgs.podman}/bin/podman cp "$cid:/opt/openclaw-skills/." "${skillsDir}/"
            ${pkgs.podman}/bin/podman rm "$cid"
            # Overlay repo custom skills (e.g. gog from actual CLI)
            if [ -d "${composeDir}/skills" ]; then
              for skill in "${composeDir}/skills"/*/; do
                [ -d "$skill" ] || continue
                ${pkgs.coreutils}/bin/cp -r "$skill" "${skillsDir}/"
              done
            fi
            ${pkgs.coreutils}/bin/chmod -R a+rX "${skillsDir}"
          ''))
        ];

        # Use podman-compose to start detached, then attach to container logs
        # so systemd tracks the process and sees container output.
        ExecStart = toString (pkgs.writeShellScript "openclaw-compose-up" ''
          set -eu
          podman=${pkgs.podman}/bin/podman

          # Tear down any leftover container from a previous run
          "$podman" rm -f openclaw_openclaw-gateway_1 2>/dev/null || true

          ${pkgs.podman-compose}/bin/podman-compose \
            --podman-path "$podman" \
            -f ${composeDir}/compose.yml \
            up -d

          # Attach in foreground so systemd tracks this process
          exec "$podman" logs -f openclaw_openclaw-gateway_1
        '');

        ExecStop = toString (pkgs.writeShellScript "openclaw-compose-down" ''
          ${pkgs.podman-compose}/bin/podman-compose \
            --podman-path ${pkgs.podman}/bin/podman \
            -f ${composeDir}/compose.yml \
            down || \
          ${pkgs.podman}/bin/podman rm -f openclaw_openclaw-gateway_1 || true
        '');
      };
    };
  };
}
