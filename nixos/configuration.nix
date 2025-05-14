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
	./silent-boot/boot.nix      
 
	#hardware optimization
	./hardware-optimization/hardware-configuration.nix

	#audio
	./audio/general.nix
	./audio/bluetooth.nix
        
	#networking
	./networking/networks.nix
	
	#wayland - sway
	./wayland/general.nix
	./wayland/window-manager.nix
	./wayland/login-manager.nix

       # TODO: add wayland-kde

       # virtualization
       ./virtualization/virt.nix
    ];

  nixpkgs.config = {
      allowUnfree = true;
      packageOverrides = pkgs: {
        unstable = import unstableTarball {
          config = config.nixpkgs.config;
        };
      };
  };

  time.timeZone = "Europe/Moscow";

  environment.sessionVariables = rec {
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XCURSOR_SIZE = "24";
  };
    
  users.users.esc2 = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; 
   };
  
  environment.systemPackages = with pkgs; [
    bc
    vim
    wget
    tmux
    freshfetch
   ];

  

  #programs.mtr.enable = true;
  #programs.gnupg.agent = {
  #  enable = true;
  #  enableSSHSupport = true;
  #};

  #services.openssh.enable = true;
  #services.printing.enable = true;    

  # Doesn't work well with sway on current
  # hardware
  # services.logind.extraConfig = ''
  #   IdleAction=suspend
  # '';
  # IdleActionSec
  system.stateVersion = "22.11";
}
