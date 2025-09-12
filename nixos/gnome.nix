{ pkgs, ... }:
{
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
  ];
}


