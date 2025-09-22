{ pkgs, lib, ... }:
{
  # System-level GNOME configuration
  services.displayManager.gdm = {
    enable = true;
    # Prevent automatic session restarts that cause double login
    autoSuspend = false;
    wayland = true;
  };
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
    wlroots
    # Language switching support
    ibus
    # File chooser and context menu support
    xdg-desktop-portal-gtk
    # xdg-desktop-portal-gnome
    gtk3
    gtk4
    adwaita-icon-theme
    gnome-themes-extra
    gsettings-desktop-schemas
    # Pomodoro timer
    gnome-pomodoro
  ];

  # Internationalization configuration
  # i18n = {
  #   defaultLocale = "en_US.UTF-8";
  #   extraLocaleSettings = {
  #     LC_TIME = "ru_RU.UTF-8";
  #     LC_MONETARY = "ru_RU.UTF-8";
  #     LC_PAPER = "ru_RU.UTF-8";
  #     LC_MEASUREMENT = "ru_RU.UTF-8";
  #   };
  #   supportedLocales = [
  #     "en_US.UTF-8/UTF-8"
  #     "ru_RU.UTF-8/UTF-8"
  #   ];
  # };
  
  # Set timezone
  time.timeZone = "Europe/Moscow";

  # use ntpd-rs instead of systemd-timesyncd
  # services.timesyncd.enable = false;
  # services.ntpd-rs.enable = true;
  # services.ntpd-rs.useNetworkingTimeServers = true;
  # https://nixos.wiki/wiki/NTP



  # Configure keyboard layout for Russian/English switching
  # Note: For GNOME on Wayland, keyboard layout is configured via dconf settings below
  # services.xserver = {
  #   # enable = true;
  #   xkb = {
  #     layout = "us,ru";
  #     options = "grp:alt_shift_toggle";
  #   };
  # };

  # Enable XWayland for X11 application compatibility
  # services.xserver.desktopManager.gnome.sessionPath = [ pkgs.gnome.gnome-session-extra ];
  # programs.xwayland.enable = true;

  # GTK theme configuration to fix CSS import errors
  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [ dconf ];
  
  # XDG Desktop Portal configuration for file chooser and context menus
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = with pkgs; [
  #     xdg-desktop-portal-gtk
  #   ];
  #   # Explicitly exclude GNOME portal to prevent conflicts
  #   config = {
  #     common = {
  #       default = "gtk";
  #       "org.freedesktop.impl.portal.FileChooser" = "gtk";
  #       "org.freedesktop.impl.portal.AppChooser" = "gtk";
  #       "org.freedesktop.impl.portal.Print" = "gtk";
  #       "org.freedesktop.impl.portal.Notification" = "gtk";
  #       "org.freedesktop.impl.portal.Screenshot" = "gtk";
  #       "org.freedesktop.impl.portal.Wallpaper" = "gtk";
  #       "org.freedesktop.impl.portal.ScreenCast" = "gtk";
  #       "org.freedesktop.impl.portal.RemoteDesktop" = "gtk";
  #       "org.freedesktop.impl.portal.Background" = "gtk";
  #       "org.freedesktop.impl.portal.Session" = "gtk";
  #       "org.freedesktop.impl.portal.Account" = "gtk";
  #       "org.freedesktop.impl.portal.Email" = "gtk";
  #       "org.freedesktop.impl.portal.GameMode" = "gtk";
  #       "org.freedesktop.impl.portal.Lockdown" = "gtk";
  #       "org.freedesktop.impl.portal.Inhibit" = "gtk";
  #       "org.freedesktop.impl.portal.Device" = "gtk";
  #       "org.freedesktop.impl.portal.Location" = "gtk";
  #       "org.freedesktop.impl.portal.NetworkMonitor" = "gtk";
  #       "org.freedesktop.impl.portal.Trash" = "gtk";
  #       "org.freedesktop.impl.portal.DynamicLauncher" = "gtk";
  #       "org.freedesktop.impl.portal.GlobalShortcuts" = "gtk";
  #       "org.freedesktop.impl.portal.PowerProfileMonitor" = "gtk";
  #       "org.freedesktop.impl.portal.ProxyResolver" = "gtk";
  #       "org.freedesktop.impl.portal.Portal" = "gtk";
  #       "org.freedesktop.impl.portal.Secret" = "gtk";
  #       "org.freedesktop.impl.portal.Status" = "gtk";
  #       "org.freedesktop.impl.portal.URI" = "gtk";
  #       "org.freedesktop.impl.portal.UserInfo" = "gtk";
  #       "org.freedesktop.impl.portal.Wayland" = "gtk";
  #       "org.freedesktop.impl.portal.Access" = "gtk";
  #       "org.freedesktop.impl.portal.Settings" = "gtk";
  #       "org.freedesktop.impl.portal.Clipboard" = "gtk";
  #       "org.freedesktop.impl.portal.InputCapture" = "gtk";
  #       "org.freedesktop.impl.portal.Usb" = "gtk";
  #     };
  #   };
  # };
  
  # Enable input method framework for better language switching
  # i18n.inputMethod = {
  #   type = "ibus";
  #   enable = true;
  # };
  
  # Set default GTK theme to fix CSS import errors
  environment.variables = {
    GTK_THEME = "Adwaita:dark";
    QT_STYLE_OVERRIDE = "adwaita-dark";
    # Fix GTK paths to avoid symlink issues
    GTK_DATA_PREFIX = "${pkgs.gtk3}";
    GTK_EXE_PREFIX = "${pkgs.gtk3}";
    GTK_PATH = "${pkgs.gtk3}";
    # Use proper XDG data directories with force override to avoid conflicts
    # XDG_DATA_DIRS = lib.mkForce "${pkgs.gtk3}/share:${pkgs.gtk4}/share:${pkgs.adwaita-icon-theme}/share:${pkgs.gnome-themes-extra}/share";
    # XWayland environment variables
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    # Additional variables for proper portal support
    # XDG_CURRENT_DESKTOP = "GNOME";
    # XDG_SESSION_DESKTOP = "gnome";
    # XDG_SESSION_TYPE = "wayland";
    # Fix for missing FileChooser interface - set XDG_DESKTOP_PORTAL_DIR explicitly
    # XDG_DESKTOP_PORTAL_DIR = "/run/current-system/sw/share/xdg-desktop-portal/portals";
    # IBus environment variables
    # GTK_IM_MODULE = "ibus";
    # QT_IM_MODULE = "ibus";
    # XMODIFIERS = "@im=ibus";
    # Additional variables for file chooser and context menus
  };

  # Enable internationalization support
  # i18n = {
  #   defaultLocale = "en_US.UTF-8";
  #   supportedLocales = [
  #     "en_US.UTF-8/UTF-8"
  #     "ru_RU.UTF-8/UTF-8"
  #   ];
  #   extraLocaleSettings = {
  #     LC_ADDRESS = "ru_RU.UTF-8";
  #     LC_IDENTIFICATION = "ru_RU.UTF-8";
  #     LC_MEASUREMENT = "ru_RU.UTF-8";
  #     LC_MONETARY = "ru_RU.UTF-8";
  #     LC_NAME = "ru_RU.UTF-8";
  #     LC_NUMERIC = "ru_RU.UTF-8";
  #     LC_PAPER = "ru_RU.UTF-8";
  #     LC_TELEPHONE = "ru_RU.UTF-8";
  #     LC_TIME = "ru_RU.UTF-8";
  #   };
  # };

  # Systemd service to ensure language switching works after login
  # systemd.user.services.language-setup = {
  #   description = "Setup language switching for GNOME";
  #   wantedBy = [ "graphical-session.target" ];
  #   after = [ "graphical-session.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "/run/current-system/sw/bin/bash -c 'sleep 5 && /run/current-system/sw/bin/gsettings set org.gnome.desktop.input-sources sources \"[(''xkb'', ''us''), (''xkb'', ''ru'')]\" && /run/current-system/sw/bin/gsettings set org.gnome.desktop.input-sources xkb-options \"[''grp:alt_shift_toggle'']\"'";
  #     RemainAfterExit = true;
  #   };
  # };

  # # Resume hook to restore keyboard layout after suspend
  # systemd.user.services.keyboard-layout-resume = {
  #   description = "Restore keyboard layout after system resume";
  #   wantedBy = [ "suspend.target" ];
  #   after = [ "suspend.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "/run/current-system/sw/bin/bash -c 'sleep 2 && /run/current-system/sw/bin/gsettings set org.gnome.desktop.input-sources sources \"[(''xkb'', ''us''), (''xkb'', ''ru'')]\" && /run/current-system/sw/bin/gsettings set org.gnome.desktop.input-sources xkb-options \"[''grp:alt_shift_toggle'']\"'";
  #     RemainAfterExit = true;
  #   };
  # };

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

        # Disable workspace switching animations (moved to main interface settings below)

        "org/gnome/shell/extensions/desktop-icons-ng" = {
          enable-animations = false;
        };

        # File chooser settings to fix context menu issues
        # "org/gtk/settings/file-chooser" = {
        #   show-hidden = true;
        #   sort-directories-first = true;
        #   sort-order = "type";
        # };

        # GNOME file manager settings
        # "org/gnome/nautilus/preferences" = {
        #   show-hidden-files = true;
        #   default-folder-viewer = "list-view";
        #   search-view = "list-view";
        # };

        # Mouse settings - preserve current settings with flat acceleration
        "org/gnome/desktop/peripherals/mouse" = {
          accel-profile = "flat";
          # speed = -0.23529411764705888;
        };
      };

      # GNOME input sources configuration
      dconf.settings."org/gnome/desktop/input-sources" = {
        # Enable showing all input sources in the panel
        show-all-sources = true;
        
        # Configure keyboard layouts: US English and Russian
        sources = [
          [ "xkb" "us" ]
          [ "xkb" "ru" ]
        ];
        
        # Set Alt+Shift as the keyboard layout toggle combination
        xkb-options = [ "grp:alt_shift_toggle" ];
        
        # Clear most recently used sources (starts fresh)
        mru-sources = [];
      };

      # Additional settings to ensure language indicator appears
      dconf.settings."org/gnome/shell" = {
        enabled-extensions = [
          "searchlight@icedman.github.com"
        ];
      };

      # Systemd service to ensure input sources are properly configured after login
      # Uses script from ~/.scripts/ which is deployed via rcup
      systemd.user.services.input-sources-setup = {
        Unit = {
          Description = "Setup input sources for GNOME";
          After = [ "graphical-session.target" ];
          # Prevent conflicts by ensuring this only runs once
          ConditionPathExists = "!/tmp/input-sources-setup-done";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "/home/esc2/.scripts/setup-input-sources.sh";
          # Mark as completed to prevent re-runs
          ExecStartPost = "touch /tmp/input-sources-setup-done";
          RemainAfterExit = true;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      # Clean up marker file on logout to ensure proper setup on next login
      systemd.user.services.input-sources-cleanup = {
        Unit = {
          Description = "Clean up input sources marker file on logout";
          Before = [ "shutdown.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "rm -f /tmp/input-sources-setup-done";
          RemainAfterExit = true;
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };


      # Fix GTK theme CSS import errors
      # dconf.settings."org/gnome/desktop/interface" = {
      #   gtk-theme = lib.mkForce "Adwaita-dark";
      #   icon-theme = lib.mkForce "Adwaita";
      #   cursor-theme = lib.mkForce "Adwaita";
      #   enable-animations = false;
      # };

      # # Additional GTK settings
      # dconf.settings."org/gnome/desktop/wm/preferences" = {
      #   theme = "Adwaita";
      # };

      # # Systemd service to fix GTK CSS resource issues
      # systemd.user.services.gtk-css-fix = {
      #   Unit = {
      #     Description = "Fix GTK CSS resource issues";
      #     WantedBy = [ "graphical-session.target" ];
      #     After = [ "graphical-session.target" ];
      #   };
      #   Service = {
      #     Type = "oneshot";
      #     ExecStart = "/run/current-system/sw/bin/bash -c 'mkdir -p ~/.local/share/themes/Adwaita-dark/gtk-3.0 && cp ${pkgs.gtk3}/share/themes/Adwaita-dark/gtk-3.0/gtk.css ~/.local/share/themes/Adwaita-dark/gtk-3.0/ && export GTK_DATA_PREFIX=${pkgs.gtk3} && export GTK_EXE_PREFIX=${pkgs.gtk3} && export GTK_PATH=${pkgs.gtk3} && /run/current-system/sw/bin/gsettings set org.gnome.desktop.interface gtk-theme \"Adwaita-dark\" && /run/current-system/sw/bin/gsettings set org.gnome.desktop.interface icon-theme \"Adwaita\" && /run/current-system/sw/bin/gsettings set org.gnome.desktop.interface cursor-theme \"Adwaita\"'";
      #     RemainAfterExit = true;
      #   };
      # };


    };
}
