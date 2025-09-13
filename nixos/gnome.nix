{ pkgs, lib, ... }:
{
  # System-level GNOME configuration
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    gnome-music
    gnome-tour
    cheese
    epiphany
    geary
    totem
  ];

  environment.systemPackages = with pkgs; [
    dconf-editor
    gnome-shell-extensions
    gnome-tweaks
    sxhkd
  ];

  # Configure keyboard layout for Russian/English switching
  services.xserver = {
    xkb = {
      layout = "us,ru";
      options = "grp:alt_shift_toggle";
    };
  };

  # Enable internationalization support
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_ADDRESS = "ru_RU.UTF-8";
      LC_IDENTIFICATION = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_NAME = "ru_RU.UTF-8";
      LC_NUMERIC = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
      LC_TELEPHONE = "ru_RU.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
    };
  };

  # Systemd service to ensure language switching works after login
  systemd.user.services.language-setup = {
    description = "Setup language switching for GNOME";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/bash -c 'sleep 5 && gsettings set org.gnome.desktop.input-sources sources \"[(''xkb'', ''us''), (''xkb'', ''ru'')]\" && gsettings set org.gnome.desktop.input-sources xkb-options \"[''grp:alt_shift_toggle'']\"'";
      RemainAfterExit = true;
    };
  };

  # Resume hook to restore keyboard layout after suspend
  systemd.user.services.keyboard-layout-resume = {
    description = "Restore keyboard layout after system resume";
    wantedBy = [ "suspend.target" ];
    after = [ "suspend.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/bash -c 'sleep 2 && gsettings set org.gnome.desktop.input-sources sources \"[(''xkb'', ''us''), (''xkb'', ''ru'')]\" && gsettings set org.gnome.desktop.input-sources xkb-options \"[''grp:alt_shift_toggle'']\"'";
      RemainAfterExit = true;
    };
  };

  # Home-manager GNOME configuration
  home-manager.users.esc2 =
    { pkgs, ... }:
    {
      # Enable GNOME Shell and requested extensions for the user
      programs.gnome-shell = {
        enable = true;
        extensions = [
          #{ package = pkgs.gnomeExtensions.tiling-shell; }
          { package = pkgs.gnomeExtensions.search-light; }
        ];
      };

      # Configure GNOME Shell keyboard shortcuts
      dconf.settings = {
        "org/gnome/shell/keybindings" = {
          # Disable conflicting application switching shortcuts
          switch-to-application-1 = [ ];
          switch-to-application-2 = [ ];
          switch-to-application-3 = [ ];
          switch-to-application-4 = [ ];
          switch-to-application-5 = [ ];
          switch-to-application-6 = [ ];
          switch-to-application-7 = [ ];
          switch-to-application-8 = [ ];
          switch-to-application-9 = [ ];

          # Rectangular screenshot shortcut (Shift + Windows + S)
          "show-screenshot-ui" = [ "<Shift><Super>s" ];
        };

        # Workspace switching shortcuts (Windows + 1-6)
        "org/gnome/desktop/wm/keybindings" = {
          switch-to-workspace-1 = [ "<Super>1" ];
          switch-to-workspace-2 = [ "<Super>2" ];
          switch-to-workspace-3 = [ "<Super>3" ];
          switch-to-workspace-4 = [ "<Super>4" ];
          switch-to-workspace-5 = [ "<Super>5" ];
          switch-to-workspace-6 = [ "<Super>6" ];

          # Move window to workspace shortcuts (Shift + Windows + 1-6)
          move-to-workspace-1 = [ "<Shift><Super>1" ];
          move-to-workspace-2 = [ "<Shift><Super>2" ];
          move-to-workspace-3 = [ "<Shift><Super>3" ];
          move-to-workspace-4 = [ "<Shift><Super>4" ];
          move-to-workspace-5 = [ "<Shift><Super>5" ];
          move-to-workspace-6 = [ "<Shift><Super>6" ];

          # Close window shortcut (Shift + Windows + Q)
          close = [ "<Shift><Super>q" ];

          # Remove conflicting default shortcuts
          switch-to-workspace-left = [ ];
          switch-to-workspace-right = [ ];
          move-to-workspace-left = [ ];
          move-to-workspace-right = [ ];
          move-to-monitor-left = [ ];
          move-to-monitor-right = [ ];
          move-to-monitor-up = [ ];
          move-to-monitor-down = [ ];
        };

        # Disable workspace switching animations
        "org/gnome/desktop/interface" = {
          enable-animations = false;
        };

        "org/gnome/shell/extensions/desktop-icons-ng" = {
          enable-animations = false;
        };
      };

      # GNOME input sources configuration
      dconf.settings."org/gnome/desktop/input-sources" = {
        sources = [
          "('xkb', 'us')"
          "('xkb', 'ru')"
        ];
        xkb-options = [ "grp:alt_shift_toggle" ];
        show-all-sources = true;
      };

      # Additional settings to ensure language indicator appears
      dconf.settings."org/gnome/shell" = {
        enabled-extensions = [
          "searchlight@icedman.github.com"
        ];
      };

    };
}
