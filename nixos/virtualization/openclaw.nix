{ config, pkgs, lib, ... }:

let
  cfg = config.services.openclawGateway;

  containerGatewayPort = 18789;
  containerBridgePort = 18790;

  configDir = "${cfg.stateDir}/config";
  workspaceDir = "${cfg.stateDir}/workspace";
  envFile = "${configDir}/.env";
  configFile = "${configDir}/openclaw.json";

  hostPortPrefix =
    if cfg.bindLocalhostOnly
    then "127.0.0.1:"
    else "";

  mkPort = hostPort: containerPort: "${hostPortPrefix}${toString hostPort}:${toString containerPort}";
in
{
  options.services.openclawGateway = {
    enable = lib.mkEnableOption "OpenClaw gateway running in an OCI container (Podman)";

    image = lib.mkOption {
      type = lib.types.str;
      default = "alpine/openclaw:latest";
      description = "OCI image for the OpenClaw gateway container.";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/openclaw";
      description = "Host directory for OpenClaw config/workspace state.";
    };

    bindLocalhostOnly = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Bind the exposed gateway/bridge ports only on 127.0.0.1.";
    };

    gatewayHostPort = lib.mkOption {
      type = lib.types.port;
      default = containerGatewayPort;
      description = "Host port to expose the OpenClaw gateway UI/API on.";
    };

    bridgeHostPort = lib.mkOption {
      type = lib.types.port;
      default = containerBridgePort;
      description = "Host port to expose the OpenClaw bridge on.";
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
    systemd.services."podman-openclaw-gateway".serviceConfig.TimeoutStartSec = lib.mkForce "15min";

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 ${toString cfg.userUid} ${toString cfg.userGid} -"
      "d ${configDir} 0750 ${toString cfg.userUid} ${toString cfg.userGid} -"
      "d ${workspaceDir} 0750 ${toString cfg.userUid} ${toString cfg.userGid} -"
    ];

    system.activationScripts.openclawGatewayBootstrap = ''
      set -eu

      ${pkgs.coreutils}/bin/mkdir -p "${configDir}" "${workspaceDir}"
      ${pkgs.coreutils}/bin/chown ${toString cfg.userUid}:${toString cfg.userGid} "${configDir}" "${workspaceDir}"
      ${pkgs.coreutils}/bin/chmod 0750 "${configDir}" "${workspaceDir}"

      if [ ! -e "${configFile}" ]; then
        ${pkgs.coreutils}/bin/cat > "${configFile}" <<'EOF'
{ "gateway": { "mode": "local" } }
EOF
      fi
      ${pkgs.coreutils}/bin/chown ${toString cfg.userUid}:${toString cfg.userGid} "${configFile}"
      ${pkgs.coreutils}/bin/chmod 0600 "${configFile}"

      if [ ! -e "${envFile}" ]; then
        umask 077
        token="$(${pkgs.openssl}/bin/openssl rand -hex 32)"
        ${pkgs.coreutils}/bin/printf "OPENCLAW_GATEWAY_TOKEN=%s\n" "$token" > "${envFile}"
      fi
      ${pkgs.coreutils}/bin/chown ${toString cfg.userUid}:${toString cfg.userGid} "${envFile}"
      ${pkgs.coreutils}/bin/chmod 0600 "${envFile}"
    '';

    virtualisation.oci-containers = {
      backend = "podman";
      containers."openclaw-gateway" = {
        image = cfg.image;
        # First start may fail if the image is not already present: Podman pulls triggered by systemd units
        # have a hardcoded ~5 minute timeout in some versions. Workaround: `sudo podman pull docker.io/alpine/openclaw:latest`.
        pull = "missing";

        autoStart = true;

        # Mirrors upstream docker-compose.yml
        environment = {
          HOME = "/home/node";
          TERM = "xterm-256color";
        };
        environmentFiles = [ envFile ];

        volumes = [
          "${configDir}:/home/node/.openclaw"
          "${workspaceDir}:/home/node/.openclaw/workspace"
        ];

        ports = [
          (mkPort cfg.gatewayHostPort containerGatewayPort)
          (mkPort cfg.bridgeHostPort containerBridgePort)
        ];

        cmd = [
          "node"
          "dist/index.js"
          "gateway"
          "--bind"
          "lan"
          "--port"
          "${toString containerGatewayPort}"
        ];

        extraOptions = [
          "--init"
        ];
      };
    };
  };
}
