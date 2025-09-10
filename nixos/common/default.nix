{ config, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in

{



  nixpkgs.config = {
      allowUnfree = true;
      packageOverrides = pkgs: {
        #unstable = import unstableTarball {
        #  config = config.nixpkgs.config;
        #};
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
    git
   ];

  

  #programs.mtr.enable = true;
  #programs.gnupg.agent = {
  #  enable = true;
  #  enableSSHSupport = true;
  #};

  services.openssh.enable = true;
  #services.printing.enable = true;    

  # Doesn't work well with sway on current
  # hardware
  # services.logind.extraConfig = ''
  #   IdleAction=suspend
  # '';
  # IdleActionSec
  system.stateVersion = "22.11";
}
