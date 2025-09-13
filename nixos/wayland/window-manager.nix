{ config, pkgs, lib, ... }:

let
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-enviroment";
    executable = true;

    text = ''
      dbus-update-activation-enviroment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text =
      let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsetting-schemas/${schema.name}";
      in
      ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme 'WhiteSur-dark'
        gsettings set $gnome_schema cursor-theme 'capitaine-cursors-white'
      '';
  };

in
{
  environment.systemPackages = with pkgs; [
    alacritty
    sway
    autotiling-rs
    dbus-sway-environment
    configure-gtk
    wayland
    xdg-utils
    glib
    grim
    slurp
    wl-clipboard

    whitesur-icon-theme
    capitaine-cursors

    rofi-wayland 
    kanshi
  ];

  services.dbus.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # programs.regreet = {
  #   enable = true;
  # };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # fix issue with non-working login after suspend
  security.pam.services.swaylock = {
    text = ''
      auth include login
      auth include system-auth
    '';
  };

    # kanshi systemd service
  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    environment = {
      WAYLAND_DISPLAY="wayland-1";
      DISPLAY = ":0";
    }; 
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi -c /home/esc2/.config/kanshi/config'';
    };
  };

  # Keyboard layout restoration service
  systemd.user.services.keyboard-layout-restore = {
    description = "Restore keyboard layout after resume";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/bash -c 'sleep 2 && swaymsg input \"1:1:AT_Translated_Set_2_keyboard\" xkb_layout \"us,ru\" && swaymsg input \"1:1:AT_Translated_Set_2_keyboard\" xkb_options \"grp:win_space_toggle,grp_led:scroll\"'";
      RemainAfterExit = true;
    };
  };

  # Resume hook to restore keyboard layout
  systemd.user.services.keyboard-layout-resume = {
    description = "Restore keyboard layout after system resume";
    wantedBy = [ "suspend.target" ];
    after = [ "suspend.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/bash -c 'sleep 1 && swaymsg input \"1:1:AT_Translated_Set_2_keyboard\" xkb_layout \"us,ru\" && swaymsg input \"1:1:AT_Translated_Set_2_keyboard\" xkb_options \"grp:win_space_toggle,grp_led:scroll\"'";
      RemainAfterExit = true;
    };
  };

}
