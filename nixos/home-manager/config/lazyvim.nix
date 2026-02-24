# LazyVim via lazyvim-nixvim flake (NixVim-based).
# Provides the nvim package; do not enable programs.neovim.
{
  config,
  pkgs,
  inputs,
  ...
}:
{
  home.packages = [
    inputs.lazyvim-nixvim.packages.${pkgs.system}.default
  ];
}
