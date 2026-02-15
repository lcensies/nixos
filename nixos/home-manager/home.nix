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

  home.packages = with pkgs; [
    git
    git-lfs
    rcm
    python3
    just
    # vscodium
    code-cursor
    vscode
    #Browser
    firefox
    tor-browser
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

    # Remote desktop
    remmina 

    # Diagrams
    drawio
    #anytype
    deluge
    obs-studio

    zoom

    foliate

    chatbox
  ];

  programs.direnv = {
    enable = true;
    enableBashIntegration = true; # see note on other shells below
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # User environment variables
  home.sessionVariables = {
    XDG_DATA_DIRS = "$HOME/.nix-profile/share:$XDG_DATA_DIRS";
  };

  # Wrapper script for waypipe applications
  home.file.".local/bin/waypipe-chromium" = {
    text = ''
      #!/usr/bin/env bash
      # Wrapper script for running Chromium via waypipe from remote system
      
      # Parse VM parameter from environment or use default
      VM_NAME="''${WAYPIPE_VM:-end}"
      
      # Parse additional args
      EXTRA_ARGS=()
      while [[ $# -gt 0 ]]; do
        case $1 in
          --vm)
            VM_NAME="$2"
            shift 2
            ;;
          *)
            EXTRA_ARGS+=("$1")
            shift
            ;;
        esac
      done
      
      # Check if VM is running, start it if not
      if ! virsh list --state-running --name | grep -q "^$VM_NAME$"; then
        echo "$(date): $VM_NAME VM not running, starting it..." >> /tmp/waypipe-chromium.log
        virsh start "$VM_NAME"
        
        # Wait for VM to be running (with timeout)
        timeout=30
        elapsed=0
        while [ $elapsed -lt $timeout ]; do
          if virsh list --state-running --name | grep -q "^$VM_NAME$"; then
            echo "$(date): $VM_NAME VM started successfully" >> /tmp/waypipe-chromium.log
            break
          fi
          sleep 1
          elapsed=$((elapsed + 1))
        done
        
        if [ $elapsed -ge $timeout ]; then
          echo "$(date): Warning: $VM_NAME VM may not have started in time" >> /tmp/waypipe-chromium.log
        fi
      else
        echo "$(date): $VM_NAME VM already running" >> /tmp/waypipe-chromium.log
      fi
      
      # Set Wayland display
      export WAYLAND_DISPLAY=''${WAYLAND_DISPLAY:-wayland-1}
      
      # Log for debugging
      echo "$(date): Starting waypipe chromium on VM: $VM_NAME" >> /tmp/waypipe-chromium.log
      echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY" >> /tmp/waypipe-chromium.log
      
      # Run waypipe with chromium on remote host
      # The SSH hostname should match the VM name
      exec ${pkgs.waypipe}/bin/waypipe --no-gpu ssh "$VM_NAME" chromium --ozone-platform=wayland "''${EXTRA_ARGS[@]}"
    '';
    executable = true;
  };

  # Test wrapper script
  home.file.".local/bin/test-desktop-entry" = {
    text = ''
      #!/usr/bin/env bash
      # Simple test script to verify desktop entries work
      ${pkgs.libnotify}/bin/notify-send "Desktop Entry Works!" "This custom desktop entry is functioning correctly."
    '';
    executable = true;
  };

  # Simple test desktop entry - launches a test notification
  xdg.desktopEntries.test-desktop-entry = {
    name = "Test Desktop Entry";
    genericName = "Test Application";
    exec = "/home/esc2/.local/bin/test-desktop-entry";
    icon = "dialog-information";
    terminal = false;
    categories = [ "Utility" ];
    comment = "Simple test to verify custom desktop entries work";
  };

  # Custom desktop entry for waypipe chromium
  xdg.desktopEntries.arch-chromium = {
    name = "End Chromium (Remote)";
    genericName = "Web Browser";
    exec = "/home/esc2/.local/bin/waypipe-chromium %U";
    icon = "chromium";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    comment = "Chromium browser running on end VM via waypipe";
    mimeType = [ "text/html" "text/xml" ];
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
