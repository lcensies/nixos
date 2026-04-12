{ pkgs, config, ... }:
{
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

}
