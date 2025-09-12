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
    XCURSOR_SIZE = "64";
  };

  # Font rendering tweaks to reduce font glitches/blur
  fonts.fontconfig.localConf = ''
    <match target="pattern">
      <edit name="antialias" mode="assign"><bool>true</bool></edit>
      <edit name="hinting" mode="assign"><bool>true</bool></edit>
      <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
      <edit name="rgba" mode="assign"><const>rgb</const></edit>
      <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
    </match>
  '';

  # FZF configuration
  environment.variables = {
    FZF_DEFAULT_OPTS = "--height 40% --reverse --border";
  };
    
  users.users.esc2 = {
     isNormalUser = true;
     extraGroups = [ "wheel" "bluetooth" "audio" ]; 
     shell = pkgs.zsh;
     ignoreShellProgramCheck = true;
   };
  
  environment.systemPackages = with pkgs; [
    bc
    vim
    neovim
    wget
    tmux
    freshfetch
    git
    nodejs_24
    rcm
    gnumake
    go
    ruby
    zsh
    starship
    kitty
    zoxide
    jq  
    fzf
    ripgrep
    zsh-fzf-tab
    yq
    lazygit
    just
    tmuxinator
    nekoray
    zoxide
    atuin
    rofi-power-menu
    impala
    bluetuith
   ];

  services.resolved.enable = true; 
  programs.nekoray.tunMode.enable= true;
  #programs.mtr.enable = true;
  #programs.gnupg.agent = {
  #  enable = true;
  #  enableSSHSupport = true;
  #};

  services.openssh.enable = true;
  #services.printing.enable = true;    

  # Shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    # Enable atuin zsh integration
  };

  # Doesn't work well with sway on current
  # hardware
  # services.logind.extraConfig = ''
  #   IdleAction=suspend
  # '';
  # IdleActionSec
  system.stateVersion = "22.11";
}
