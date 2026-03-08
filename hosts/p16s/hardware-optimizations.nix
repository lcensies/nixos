{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  # nixos-hardware profile for Lenovo ThinkPad P16s Gen 4 AMD
  # Pulls in common-cpu-amd, common-cpu-amd-pstate, common-gpu-amd, and
  # the P16s-specific quirks (fingerprint reader, etc.)
  # https://github.com/NixOS/nixos-hardware/tree/master/lenovo/thinkpad/p16s/amd/gen4
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p16s-amd-gen4
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-hidpi
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
    "uas"
    "sd_mod"
  ];

  boot.initrd.kernelModules = [
    "amdgpu"
    "uas"
    "usbcore"
    "usb_storage"
    "vfat"
    "exfat"
    "nls_cp437"
    "nls_iso8859_1"
    # microSD
    "sd_mod"
    "mmc_core"
    "mmc_block"
    "rtsx_pci_sdmmc"
  ];

  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Improve color/brightness accuracy in power saving
  boot.kernelParams = [ "amdgpu.abmlevel=0" ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  environment.systemPackages = with pkgs; [
    powertop
    ryzenadj
  ];

  # tuned + auto-epp (prefer over tlp to avoid conflict)
  services.tlp.enable = false;
  services.tuned = {
    enable = true;
    settings.dynamic_tuning = true;
  };

  services.auto-epp = {
    enable = true;
    settings.Settings = {
      epp_state_for_AC = "balance_performance";
      epp_state_for_BAT = "power";
    };
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  hardware.firmware = with pkgs; [ linux-firmware ];
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
    mesa
    vulkan-loader
    vulkan-tools
  ];

  hardware.sensor.iio.enable = true;

  nixpkgs.config.cudaSupport = false;
  nixpkgs.config.rocmSupport = true;
}
