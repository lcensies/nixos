{ config, pkgs, ... }:

let
  nix-search = pkgs.writeShellScriptBin "nix-search" ''
    ${pkgs.nix}/bin/nix search nixpkgs "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    nix-search
  ];
}

