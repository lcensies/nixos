{ inputs, ... }:
{
  imports = [
    ./common
    ./audio
    ./networking
    ./virtualization
    ./silent-boot
    ./gaming
    ./flatpak
    # ./wayland  # Disabled to prevent conflict with GNOME GDM
  ];
}
