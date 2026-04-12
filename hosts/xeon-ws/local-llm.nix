# xeon-ws: Ollama via official container image (Podman + CDI GPU).
# No Nix-built ollama/vLLM — avoids heavy CUDA rebuilds; data persists in /var/lib/ollama.
# API: http://127.0.0.1:11434 — RTX 5090: OLLAMA_FLASH_ATTENTION=1 inside the container.
# Pull models manually: `podman exec ollama ollama pull <name>` (no auto-pull on boot).
#
# Boot: Ollama does not start automatically unless `services.local-llm.ollama.autostart = true`
# (default false — avoids boot stalls from network-online / image pulls). Start manually:
#   systemctl start ollama-container
#
# GPU: requires proprietary nvidia + matching boot kernel (see hosts/xeon-ws/nvidia.nix).
# Verify: host `nvidia-smi`, then `sudo podman exec ollama nvidia-smi` after the container is up.

{ pkgs, lib, config, ... }:
let
  cfg = config.services.local-llm.ollama;

  ollamaImage = "docker.io/ollama/ollama:latest";
  ollamaPort = 11434;
  podman = lib.getExe pkgs.podman;

  ollamaRun = pkgs.writeShellScript "ollama-container-run.sh" ''
    set -euo pipefail
    exec "${podman}" run --rm \
      --pull=missing \
      --name ollama \
      --replace \
      --device nvidia.com/gpu=all \
      -v /var/lib/ollama:/root/.ollama \
      -p ${toString ollamaPort}:11434 \
      -e OLLAMA_FLASH_ATTENTION=1 \
      -e OLLAMA_NUM_PARALLEL=${toString cfg.numParallel} \
      -e OLLAMA_MAX_LOADED_MODELS=${toString cfg.maxLoadedModels} \
      -e NVIDIA_VISIBLE_DEVICES=all \
      -e NVIDIA_DRIVER_CAPABILITIES=compute,utility \
      ${ollamaImage}
  '';
in
{
  options.services.local-llm.ollama = {
    autostart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        If true, start the Ollama container when multi-user.target is reached.
        Leave false to avoid boot delays (network-online waits, registry pulls).
        Start manually with: systemctl start ollama-container
      '';
    };
    numParallel = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = ''
        OLLAMA_NUM_PARALLEL inside the container (concurrent requests per model; raises VRAM use).
      '';
    };
    maxLoadedModels = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "OLLAMA_MAX_LOADED_MODELS — cap simultaneous resident models.";
    };
  };

  config = {
    hardware.nvidia-container-toolkit.enable = true;

    # CLI talks to the container (same default host/port).
    environment.systemPackages = [ pkgs.ollama ];

    systemd.services.ollama-container = {
      description = "Ollama LLM server (official docker.io/ollama/ollama image, Podman)";
      # network.target only — avoid network-online.target (often blocks boot waiting for "online")
      # After CDI generator: --device nvidia.com/gpu=all needs /var/run/cdi (see hardware.nvidia-container-toolkit)
      after = [
        "network.target"
        "nvidia-container-toolkit-cdi-generator.service"
      ];
      wantedBy = lib.mkIf cfg.autostart [ "multi-user.target" ];
      path = [ pkgs.podman ];
      serviceConfig = {
        Type = "exec";
        StateDirectory = "ollama";
        # No ExecStartPre podman pull: pulls block boot/registry; image fetch is --pull=missing on run.
        ExecStart = "${ollamaRun}";
        Restart = "on-failure";
        RestartSec = "10s";
        # Failsafe if pull or GPU init ever wedges (does not fix root cause but avoids infinite job)
        TimeoutStartSec = "600";
      };
    };
  };
}
