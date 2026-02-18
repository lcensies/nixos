{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.extraSpecialArgs = { inherit inputs; };

  home-manager.users.esc2 =
    { config, pkgs, ... }:
    {
      imports = [
        (import ./home.nix { inherit config pkgs inputs; })
        ./config/ml.nix
      ];
    };
}
