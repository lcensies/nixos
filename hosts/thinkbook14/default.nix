{ inputs, ... }:
{
  imports = [
    ../../nixos/default-vm.nix
    inputs.disko.nixosModules.disko
    ./hardware-configuration-thinkbook14.nix
    ./hardware-optimizations.nix
    ../../nixos/gnome.nix
    #./disko.nix
  ];

  # Allow wheel users to use sudo without password
  security.sudo.wheelNeedsPassword = false;
}
