{ config, pkgs, ...}:
{
  imports = [
    ./login-manager.nix
    ./window-manager.nix
  ];
  environment.extraInit = ''
      #Turn off gui for ssh auth
      unset -v SSH_ASKPASS
    '';

  environment.sessionVariables = rec {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
    # OZONE_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    # Reduce glitches on some GPUs by avoiding DRM modifiers
    WLR_DRM_NO_MODIFIERS = "1";
    # Force Electron/Chromium to use Wayland backend
    NIXOS_OZONE_WL = "1";
    # Improve Electron font rendering and Wayland usage in some apps (e.g. Obsidian)
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };
  users.users.esc2.extraGroups = [ "video" ];
  programs.light.enable = true;

  environment.systemPackages = with pkgs; [
    wlroots
  ];
}
