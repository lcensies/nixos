{ inputs, ... }:
{
  services.openclawGateway.enable = true;

  imports = [
    ./common
    ./audio
    ./networking
    ./virtualization
    ./silent-boot
    ./gaming
    ./flatpak
    ./development
    ./backups
    ./optimization
    # ./wayland  # Disabled to prevent conflict with GNOME GDM
  ];
}
