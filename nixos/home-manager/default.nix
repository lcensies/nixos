{ config, pkgs, inputs, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.esc2 = import ./home.nix;
}
