# LibreWolf in Podman: official Debian packages inside OCI, launched with host
# Wayland + PipeWire + session D-Bus so WebRTC (mic/screen) can use xdg-desktop-portal.
{ pkgs, ... }:
let
  containerfile = ./librewolf-podman/Containerfile;
  buildCtx = pkgs.runCommand "librewolf-podman-image-context" { } ''
    mkdir -p "$out"
    cp ${containerfile} "$out/Containerfile"
  '';
  imageTag =
    "nix-"
    + builtins.substring 0 11 (builtins.hashString "sha256" (builtins.readFile containerfile));
  imageRef = "localhost/librewolf-podman:${imageTag}";

  launcher = pkgs.writeShellScriptBin "librewolf" ''
    set -euo pipefail
    export MOZ_ENABLE_WAYLAND=''${MOZ_ENABLE_WAYLAND:-1}

    IMAGE="${imageRef}"
    if ! ${pkgs.podman}/bin/podman image exists "$IMAGE" &>/dev/null; then
      echo "Building LibreWolf container image (one-time; Debian base + official LibreWolf repo)…" >&2
      ${pkgs.podman}/bin/podman build --pull=newer \
        -f "${buildCtx}/Containerfile" \
        -t "$IMAGE" \
        "${buildCtx}"
    fi

    DATA_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/librewolf-podman"
    mkdir -p "$DATA_DIR"

    RUN_ARGS=(
      --rm
      --name librewolf-browser
      --replace
      --userns=keep-id
      --ipc=host
      --shm-size=1g
      --security-opt=no-new-privileges
      -e DISPLAY
      -e WAYLAND_DISPLAY
      -e XDG_CURRENT_DESKTOP
      -e XDG_SESSION_TYPE
      -e XDG_SESSION_CLASS
      -e XDG_RUNTIME_DIR
      -e MOZ_ENABLE_WAYLAND
      -e GDK_BACKEND
      -e DBUS_SESSION_BUS_ADDRESS
      -e DESKTOP_SESSION
      -e TZ
      # Portal + PipeWire + Wayland socket live under the user runtime dir
      -v "''${XDG_RUNTIME_DIR:?}:''${XDG_RUNTIME_DIR}"
      -v "$DATA_DIR:/home/librewolf"
      -e HOME=/home/librewolf
      -w /home/librewolf
      --user "$(id -u):$(id -g)"
      # Fonts from host
      -v /usr/share/fonts:/usr/share/fonts:ro
      -v /etc/fonts:/etc/fonts:ro
    )
    # DRM (VA-API); NVIDIA uses CDI below when available
    if [[ -d /dev/dri ]]; then
      RUN_ARGS+=(--device /dev/dri)
    fi

    # Pass host audio/video groups when present (microphone / camera)
    for g in audio video render; do
      gid=$(getent group "$g" | cut -d: -f3 || true)
      if [[ -n "''${gid:-}" ]]; then
        RUN_ARGS+=(--group-add "$gid")
      fi
    done

    # Webcam / v4l when present
    shopt -s nullglob
    for dev in /dev/video*; do
      [[ -e "$dev" ]] && RUN_ARGS+=(--device "$dev")
    done
    shopt -u nullglob

    # NVIDIA (xeon-ws + nvidia-container-toolkit / CDI)
    if [[ -e /dev/nvidia0 ]]; then
      RUN_ARGS+=(--device nvidia.com/gpu=all)
    fi

    exec ${pkgs.podman}/bin/podman run "''${RUN_ARGS[@]}" "$IMAGE" "$@"
  '';

  desktop = pkgs.makeDesktopItem {
    name = "librewolf-podman";
    desktopName = "LibreWolf";
    genericName = "Web Browser";
    comment = "LibreWolf in Podman (Wayland, PipeWire, portals)";
    icon = "librewolf";
    exec = "librewolf %u";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    mimeTypes = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };

in
{
  environment.systemPackages = [
    launcher
    desktop
  ];
}
