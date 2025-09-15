{ inputs, ... }:
{
  imports = [
    ./common
    ./audio
    ./networking
    ./virtualization
    ./silent-boot
    ./wayland
  ];
}
