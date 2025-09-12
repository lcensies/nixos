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
  };
  users.users.esc2.extraGroups = [ "video" ];
  programs.light.enable = true;

  environment.systemPackages = with pkgs; [
    wlroots
  ];
}
