{
  config,
  pkgs,
  inputs,
  outputs,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # Back up existing files (e.g. ~/.mozilla/firefox/profiles.ini) instead of failing activation
  home-manager.backupFileExtension = "backup";

  home-manager.extraSpecialArgs = { inherit inputs outputs; };

  home-manager.users.esc2 =
    { config, pkgs, ... }:
    {
      imports = [
        (import ./home.nix { inherit config pkgs inputs; })
        ./config/ml.nix
        ./config/dotfiles.nix
      ];
    };
}
