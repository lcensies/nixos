{ pkgs, config, ... }:
{
  # Binary caches for pre-built CUDA packages (avoids local compilation)
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://cuda-maintainers.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSjDg="
    ];
    # Limit parallelism to avoid OOM during heavy CUDA/OpenCV compilation (32GB RAM, no swap)
    max-jobs = 2;
    cores = 4;
  };

  # Proprietary NVIDIA drivers with CUDA support for RTX 5090
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false; # Use proprietary driver
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
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
    vllm
  ];

  # Make CUDA libraries available system-wide
  environment.variables = {
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
  };

}
