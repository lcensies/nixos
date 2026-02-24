# Wrapper flake that exposes nixpkgs with the neovim-unwrapped tree-sitter
# grammar fix (src/url mismatch). Used as nixpkgs input by lazyvim-nix so
# its evaluation doesn't hit the broken neovim-unwrapped.
{
  description = "nixpkgs with neovim-unwrapped overlay";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      neovimOverlay = nixpkgsPath: _final: prev: {
        neovim-unwrapped = prev.callPackage (nixpkgsPath + "/pkgs/by-name/ne/neovim-unwrapped/package.nix") {
          treesitter-parsers = let
            raw = import (nixpkgsPath + "/pkgs/by-name/ne/neovim-unwrapped/treesitter-parsers.nix") { fetchurl = prev.fetchurl; };
          in prev.lib.mapAttrs (name: grammar:
            if grammar ? src then grammar
            else grammar // { src = prev.fetchurl { url = grammar.url; hash = grammar.hash; }; }
          ) raw;
        };
      };
      overlay = neovimOverlay nixpkgs.outPath;
    in
    {
      # Pass through so flake-parts and other consumers see a full nixpkgs-like flake
      inherit (nixpkgs) lib;
      legacyPackages = nixpkgs.lib.genAttrs systems (system:
        import nixpkgs { inherit system; overlays = [ overlay ]; }
      );
    };
}
