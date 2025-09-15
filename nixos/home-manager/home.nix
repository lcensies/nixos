{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # ./config/git.nix
    ./config/bashrc.nix
    # ./config/alacritty.nix
    #./config/neovim.nix
    # ./config/firefox.nix
    # ./config/yt-dlp.nix


    # Sway specific
    #./config/theme.nix
    #./config/waybar.nix
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

    acpi # battery status

    imv # image viewer
    nix-prefetch-github # get hash and head from github repo

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
    # telegram-desktop fuck telegram, don't need it anymore

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

    # Remote desktop
    remmina 
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
      SuccessExitStatus = [
        "0"
        "2"
      ];
      TimeoutStopSec = 5;
      KillMode = "mixed";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Packer QEMU plugin installation service - runs once after system boot
  systemd.user.services.packer-qemu-plugin = {
    Unit = {
      Description = "Install Packer QEMU plugin";
      After = [ "network.target" "graphical-session.target" ];
      Wants = [ "network.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "install-packer-qemu-plugin" ''
        #!/bin/bash
        set -euo pipefail
        
        # Check if packer is available
        if ! command -v packer >/dev/null 2>&1; then
          echo "Packer not found, skipping plugin installation"
          exit 0
        fi
        
        # Check if QEMU plugin is already installed
        if packer plugins installed | grep -q "github.com/hashicorp/qemu"; then
          echo "Packer QEMU plugin already installed"
          exit 0
        fi
        
        echo "Installing Packer QEMU plugin..."
        packer plugins install github.com/hashicorp/qemu
        
        if packer plugins installed | grep -q "github.com/hashicorp/qemu"; then
          echo "Packer QEMU plugin installed successfully"
        else
          echo "Failed to install Packer QEMU plugin"
          exit 1
        fi
      '';
      RemainAfterExit = true;
      StandardOutput = "journal";
      StandardError = "journal";
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
