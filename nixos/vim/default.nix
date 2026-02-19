{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    neovim
    # Neovim / editor tooling (e.g. :checkhealth, Telescope, go.nvim)
    fd
    golangci-lint
  ];
}
