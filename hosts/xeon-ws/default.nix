{ inputs, pkgs, lib, ... }:
{
  imports = [
    ../../nixos/default.nix
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ../../nixos/gnome.nix
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
}
