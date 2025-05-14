{ config, pkgs, ... }:
{
  imports = [
	# ./config/git.nix
	# ./config/theme.nix
	./config/bashrc.nix
	# ./config/alacritty.nix
	./config/neovim.nix
        ./config/waybar.nix
        # ./config/yt-dlp.nix
  ];
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
        git 
        rcm
        python3
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
        nerdfonts
        
	# Note taking
	obsidian
        ];

  home.username = "esc2";
  home.homeDirectory = "/home/esc2";
  home.stateVersion = "22.11";


  programs.home-manager.enable = true;

}
