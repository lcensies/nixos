{ inputs, ... }:
{
  imports = [
    ./common
    ./audio
    ./networking
    ./virtualization
    ./silent-boot
    # ./wayland  # Disabled to prevent conflict with GNOME GDM
  ];
}
