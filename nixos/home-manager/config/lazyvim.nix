# LazyVim via root flake `packages.nvim-lazyvim` (nix-community/nixvim).
# Provides the nvim package; do not enable programs.neovim.
{
  config,
  pkgs,
  outputs,
  ...
}:
{
  home.packages = [
    outputs.packages.${pkgs.system}.nvim-lazyvim
  ];
}
