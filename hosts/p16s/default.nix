{ inputs, ... }:
{
  imports = [
    ../../nixos/default.nix
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ./hardware-optimizations.nix
    ../../nixos/gnome.nix
    #./disko.nix
  ];

  security.sudo.wheelNeedsPassword = false;
}
