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
    ./browsers/librewolf-podman.nix
    ./development
    ./backups
    ./optimization
    # ./wayland  # Disabled to prevent conflict with GNOME GDM
  ];
}
