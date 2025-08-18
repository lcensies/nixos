{ config, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in

{
  #silent boot
  # disabledModules = ["system/boot/stage-2.nix" "system/boot/stage-1.nix" "system/etc/etc.nix"];  

  imports =
    [
	#silent boot
	./silent-boot
 
	#hardware optimization

	#audio
	./audio/general.nix
	./audio/bluetooth.nix
        
	#networking
	./networking
	
	#wayland - sway
	./wayland
	
	./common

       # TODO: add wayland-kde

       # virtualization
       ./virtualization/virt.nix
    ]
    ++ lib.optional (config.machineType == "thinkbook-14") ./hardware-optimization/hardware-configuration-thinkbook-14.nix
    ++ lib.optional (config.machineType == "vmware-vm") ./hardware-optimization/hardware-configuration-vmware-vm.nix

}
