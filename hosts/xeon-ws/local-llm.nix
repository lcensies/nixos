# xeon-ws: Ollama via official container image (Podman + CDI GPU).
# No Nix-built ollama/vLLM — avoids heavy CUDA rebuilds; data persists in /var/lib/ollama.
# API: http://127.0.0.1:11434 — RTX 5090: OLLAMA_FLASH_ATTENTION=1 inside the container.
# Default model is pulled once by ollama-pull-models after the container is up.

{ pkgs, lib, ... }:
let
  ollamaImage = "docker.io/ollama/ollama:latest";
  ollamaPort = 11434;
  podman = lib.getExe pkgs.podman;

  ollamaRun = pkgs.writeShellScript "ollama-container-run.sh" ''
    set -euo pipefail
    exec "${podman}" run --rm \
      --name ollama \
      --replace \
      --device nvidia.com/gpu=all \
      -v /var/lib/ollama:/root/.ollama \
      -p ${toString ollamaPort}:11434 \
      -e OLLAMA_FLASH_ATTENTION=1 \
      ${ollamaImage}
  '';

  ollamaPullModels = pkgs.writeShellScript "ollama-pull-default-models.sh" ''
    set -euo pipefail
    for _ in $(seq 1 120); do
      if "${podman}" exec ollama ollama list >/dev/null 2>&1; then
        break
      fi
      sleep 1
    done
    "${podman}" exec ollama ollama pull qwen3-coder-next
  '';
in
{
  hardware.nvidia-container-toolkit.enable = true;

  # CLI talks to the container (same default host/port).
  environment.systemPackages = [ pkgs.ollama ];

  systemd.services.ollama-container = {
    description = "Ollama LLM server (official docker.io/ollama/ollama image, Podman)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "exec";
      StateDirectory = "ollama";
      ExecStartPre = "${podman} pull ${ollamaImage}";
      ExecStart = "${ollamaRun}";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };

  systemd.services.ollama-pull-models = {
    description = "Pull default Ollama models into persistent store";
    after = [
      "network-online.target"
      "ollama-container.service"
    ];
    requires = [ "ollama-container.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${ollamaPullModels}";
    };
  };
}
