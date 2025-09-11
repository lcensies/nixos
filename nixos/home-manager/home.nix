{ config, pkgs, inputs, ... }:
{
  imports = [
	# ./config/git.nix
  ./config/theme.nix
	./config/bashrc.nix
	# ./config/alacritty.nix
	#./config/neovim.nix
        ./config/waybar.nix
        # ./config/firefox.nix
        # ./config/yt-dlp.nix
  ];
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
        git 
        rcm
        python3
				just
	# vscodium

	#Browser
	firefox
	chromium
	qutebrowser

	#CLI program
	kpcli #password manager
	acpi #battery status

	imv #image viewer
	nix-prefetch-github #get hash and head from github repo

	#Color palette
	eyedropper
	
	#File browser
	xfce.thunar
	
	#Video viewer
	haruna

	#Video editor
	shotcut
	
	#Image editor
	pinta
	inkscape

	#Messaging app
	# signal-desktop
	telegram-desktop

	#Office suite
	libreoffice

	#Font
	jetbrains-mono
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        nerd-fonts.hack
        
	# Note taking
	obsidian
        ];

    programs.direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };


  home.username = "esc2";
  home.homeDirectory = "/home/esc2";
  home.stateVersion = "24.05";


  programs.home-manager.enable = true;

  # Disable input methods to avoid fcitx5 issues
  i18n.inputMethod.enabled = null;

}
