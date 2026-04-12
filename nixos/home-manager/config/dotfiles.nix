# Flake input `dotfiles` → ~/.dotfiles symlink + rcup on activation.
# Bump: nix flake lock --update-input dotfiles; dev: --override-input dotfiles /path/to/checkout
{ lib, pkgs, inputs, ... }:
{
  home.file.".dotfiles".source = inputs.dotfiles;

  home.activation.dotfilesRcup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.rcm}/bin/rcup -v
  '';
}
