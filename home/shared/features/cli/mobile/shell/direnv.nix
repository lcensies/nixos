{ pkgs, ... }:
{
  # https://github.com/nix-community/nix-direnv#via-home-manager
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.enableNushellIntegration = true;

  home.packages = with pkgs; [
    # https://www.jetpack.io/devbox
    devbox
    # https://devenv.sh
    devenv
  ];
}
