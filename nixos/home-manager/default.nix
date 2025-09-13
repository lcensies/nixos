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

  # Override fcitx5 package to fix the missing libsForQt5.fcitx5-with-addons issue
  nixpkgs.config.packageOverrides = pkgs: {
    libsForQt5 = pkgs.libsForQt5.overrideScope (
      final: prev: {
        fcitx5-with-addons = pkgs.fcitx5-with-addons;
      }
    );
  };

  home-manager.users.esc2 = { config, pkgs, ... }: import ./home.nix { inherit config pkgs inputs; };
}
