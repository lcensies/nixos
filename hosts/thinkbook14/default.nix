{ inputs, ... }:
{
  imports = [
    ../../nixos/default.nix
    inputs.disko.nixosModules.disko
    inputs.determinate.nixosModules.default
    ./hardware-configuration-thinkbook14.nix
    ./hardware-optimizations.nix
    ../../nixos/gnome.nix
    #./disko.nix
  ];

  # Allow wheel users to use sudo without password
  security.sudo.wheelNeedsPassword = false;
}
