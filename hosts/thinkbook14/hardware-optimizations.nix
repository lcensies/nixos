{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  

  # Import upstream nixos-hardware common modules similar to os/hosts/akahitoha
  imports = with inputs.nixos-hardware.nixosModules; [
    common-cpu-amd
    common-cpu-amd-pstate
    common-gpu-amd
    common-pc-laptop
    common-pc-ssd
    common-hidpi
  ];

  # Enable NFS support
  # boot.supportedFilesystems = [ "nfs" ];
  # services.rpcbind.enable = true; # needed for NFS

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
    "uas"
    "sd_mod"
  ];

  boot.initrd.kernelModules = [
    # Ensure AMDGPU is available early and storage helpers for FDE USB key, etc.
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

  # Battery life tools
  environment.systemPackages = with pkgs; [
    powertop
    ryzenadj
  ];

  # Prefer tuned + auto-epp instead of tlp (conflict)
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
    powertop.enable = true; # powertop --auto-tune
  };

  # Run ryzenadj once on boot with power-saving profile
  # Temporarily disabled due to hardware compatibility issues
  # systemd.services.ryzenadj = {
  #   description = "ryzenadj --power-saving";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${lib.getExe pkgs.ryzenadj} --power-saving";
  #   };
  # };

  # Firmware and graphics
  hardware.firmware = with pkgs; [ linux-firmware ];
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true; # 32-bit Vulkan for games
  hardware.graphics.extraPackages = with pkgs; [ rocmPackages.clr.icd ];

  # Ambient light sensor (ALS)
  hardware.sensor.iio.enable = true;

  # ROCm support flags
  nixpkgs.config.cudaSupport = false;
  nixpkgs.config.rocmSupport = true;


}
