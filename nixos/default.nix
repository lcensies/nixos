{ inputs, ... }:
{
  imports = [
    ./common
    ./vim
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
