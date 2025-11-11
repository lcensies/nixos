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
    ./development
    # ./wayland  # Disabled to prevent conflict with GNOME GDM
    ./private  # Private configuration (gitignored)
  ];
}
