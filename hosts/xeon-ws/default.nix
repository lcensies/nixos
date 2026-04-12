{ inputs, pkgs, lib, ... }:
{
  imports = [
    ../../nixos/default.nix
    # No ./disko.nix: importing disko's module without disko.devices still interferes with swapDevices
    # merge (nix-community/disko#678). Re-add inputs.disko.nixosModules.disko only for disko-install.
    ./hardware-configuration.nix
    ../../nixos/gnome.nix
    ./gnome-power.nix
    ./freeze-mitigations.nix
    ./remote-session-stability.nix
    ./nvidia.nix
    ./local-llm.nix
  ];

  # Legacy/BIOS mode — install GRUB to MBR of the NVMe disk
  # Disk has a 1M BIOS boot partition (nvme0n1p4) for GPT+GRUB
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    efiSupport = false;
  };
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  security.sudo.wheelNeedsPassword = false;

  # Swap + zram: Nix/CUDA builds spike RAM.
  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];
  zramSwap.enable = true;
  zramSwap.memoryPercent = 25;

  # `freeze-mitigations.nix`: Xorg + shallower C-states for whole-machine idle hangs (see that file).
  # If freezes persist: try `boot.kernelPackages = pkgs.linuxPackages` instead of _latest; capture
  # `journalctl -b -1` after a forced reset if you can.
}
