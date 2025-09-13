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
	code-cursor 
  vscode
	#Browser
	firefox
  # Second firefox
	librewolf
  # For compatibility
  chromium
  # Just for fun 
	qutebrowser
  

	# Password manager
	keepassxc

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

	# File synchronization
	syncthing
        ];

    programs.direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

  # Syncthing service - managed manually via systemd user service
  systemd.user.services.syncthing = {
    Unit = {
      Description = "Syncthing - Open Source Continuous File Synchronization";
      Documentation = "man:syncthing(1)";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.syncthing}/bin/syncthing serve --config=/home/esc2/.config/syncthing --data=/home/esc2/.local/share/syncthing --no-browser --no-restart";
      Restart = "on-failure";
      RestartSec = 5;
      SuccessExitStatus = [ "0" "2" ];
      TimeoutStopSec = 5;
      KillMode = "mixed";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.username = "esc2";
  home.homeDirectory = "/home/esc2";
  home.stateVersion = "24.05";


  programs.home-manager.enable = true;


}
