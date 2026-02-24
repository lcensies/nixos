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
    # ./wayland  # Disabled to prevent conflict with GNOME GDM
  ];
}
