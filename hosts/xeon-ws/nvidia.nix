{ pkgs, config, lib, ... }:
let
  # nvidia-container-toolkit CDI generator can run before the kernel module is ready (NVML:
  # "Driver Not Loaded"), which fails nixos-rebuild switch — see NixOS/nixpkgs#451912.
  nvidiaCdiWaitNvml = pkgs.writeShellScript "nvidia-cdi-wait-nvml" ''
    set -euo pipefail
    NVSMI="${lib.getExe' config.hardware.nvidia.package "nvidia-smi"}"
    for _ in $(seq 1 120); do
      if "$NVSMI" -L &>/dev/null; then
        exit 0
      fi
      sleep 1
    done
    echo "nvidia-cdi-generator: nvidia-smi still failing after 120s (driver not loaded?)" >&2
    exit 1
  '';
in
{
  # If `nvidia-smi` fails and `lsmod` shows nouveau: you are likely booted into an OLD kernel
  # while the nvidia package matches `boot.kernelPackages` (see `readlink /run/booted-system/kernel`
  # vs `readlink /run/current-system/kernel`). Reboot so the running kernel matches the
  # generation — otherwise CUDA/Ollama fall back to CPU.

  # CPU governor: helps prefill/tokenization when the CPU is on the hot path.
  powerManagement.cpuFreqGovernor = "performance";

  # systemd PPD profile (GNOME also uses this; complements cpufreq governor).
  systemd.services.xeon-ws-performance-profile = {
    description = "Set power-profiles-daemon to performance (LLM / GPU workloads)";
    wantedBy = [ "multi-user.target" ];
    after = [ "power-profiles-daemon.service" ];
    wants = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance";
    };
  };

  # CUDA caches: use extra-* so they persist in /etc/nix/nix.conf and append to defaults
  # (cache.nixos.org + common substituters) instead of replacing the substituters list.
  # cuda-maintainers tracks nixpkgs-unstable for prebuilt CUDA.
  nix.settings = {
    extra-substituters = [
      "https://cuda-maintainers.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSjDg="
    ];
    # Prefer fetching on the machine that is doing the build instead of falling back to local compilation.
    builders-use-substitutes = true;
    # RTX/CUDA builds are RAM-heavy on this host; keep them effectively serial and cap parallelism hard.
    max-jobs = 1;
    cores = 2;
  };

  # Proprietary NVIDIA drivers with CUDA support for RTX 5090
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false; # Use proprietary driver
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # Keeps GPU initialized (fewer first-touch / container init surprises).
    nvidiaPersistenced = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # CUDA support
  nixpkgs.config.cudaSupport = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    cudaPackages.cuda_cudart
    cudaPackages.cudatoolkit
    nvtopPackages.nvidia
  ];

  # Make CUDA libraries available system-wide
  environment.variables = {
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
  };

  # Only when local-llm (or another module) enables the toolkit.
  systemd.services.nvidia-container-toolkit-cdi-generator = lib.mkIf config.hardware.nvidia-container-toolkit.enable {
    serviceConfig = {
      ExecStartPre = [ "${nvidiaCdiWaitNvml}" ];
      Restart = "on-failure";
      RestartSec = "15s";
    };
  };

}
