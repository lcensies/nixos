{
  description = "github:lcensies/nixos";

  inputs = {
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    #home-manager.backupFileExtension = "backup";

    impermanence.url = "github:nix-community/impermanence";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    handy.url = "github:cjpais/Handy";

    preload-ng.url = "github:miguel-b-p/preload-ng";

    # nixpkgs with neovim-unwrapped tree-sitter fix (so lazyvim-nix evaluates)
    nixpkgs-neovim-fix = {
      url = "path:./nixos/nixpkgs-neovim-fix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Local LazyVim config (nixos/vim/lazyvim-nix)
    lazyvim-nixvim = {
      url = "path:./nixos/vim/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs-neovim-fix";
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      impermanence,
      home-manager,
      ...
    }:
    let
      inherit (self) outputs;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Fix neovim-unwrapped when tree-sitter grammars use url/hash instead of src
      # (nixpkgs mismatch: package.nix expects grammar.src, treesitter-parsers may give url).
      neovimOverlay = nixpkgsPath: final: prev: {
        neovim-unwrapped = prev.callPackage (nixpkgsPath + "/pkgs/by-name/ne/neovim-unwrapped/package.nix") {
          treesitter-parsers = let
            raw = import (nixpkgsPath + "/pkgs/by-name/ne/neovim-unwrapped/treesitter-parsers.nix") { fetchurl = prev.fetchurl; };
          in prev.lib.mapAttrs (name: grammar:
            if grammar ? src then grammar
            else grammar // { src = prev.fetchurl { url = grammar.url; hash = grammar.hash; }; }
          ) raw;
        };
      };
    in
    {
      #packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
      # Overlay to fix neovim-unwrapped tree-sitter grammar src/url mismatch in nixpkgs
      overlays = {
        neovim = neovimOverlay nixpkgs.outPath;
      };

      nixosConfigurations =
        let
          specialArgs = {
            inherit inputs outputs;
          };
        in
        {
          # ./hosts/vmw/README.md
          vmw = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            modules = [
              ./hosts/vmw
            ];
          };

          # ./hosts/thinkbook14/README.md
          thinkbook14 = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            modules = [
              inputs.nix-flatpak.nixosModules.nix-flatpak
              inputs.preload-ng.nixosModules.default
              ./hosts/thinkbook14
              ./nixos/home-manager # Fixed fcitx5 issue with package override
              # NUR overlay so Home Manager Firefox extensions (e.g. rycee firefox-addons) are available
              ({ inputs, ... }: { nixpkgs.overlays = [ inputs.nur.overlays.default ]; })
            ];
          };

          # ./hosts/p16s — Lenovo ThinkPad P16s Gen 4 AMD (21QR0020US)
          p16s = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            modules = [
              inputs.nix-flatpak.nixosModules.nix-flatpak
              inputs.preload-ng.nixosModules.default
              ./hosts/p16s
              ./nixos/home-manager
              ({ inputs, ... }: { nixpkgs.overlays = [ inputs.nur.overlays.default ]; })
            ];
          };

          # Rollback to original configuration
          rollback = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            modules = [
              ./hosts/rollback
            ];
          };

          # ./hosts/xeon-ws — Intel Xeon E5-2680 v3 workstation
          xeon-ws = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            modules = [
              inputs.nix-flatpak.nixosModules.nix-flatpak
              inputs.preload-ng.nixosModules.default
              ./hosts/xeon-ws
              ./nixos/home-manager
              ({ inputs, ... }: { nixpkgs.overlays = [ inputs.nur.overlays.default ]; })
            ];
          };

        };

      homeConfigurations = {
        "esc2" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux.extend inputs.nur.overlays.default;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            ./nixos/home-manager/home.nix
            ./nixos/home-manager/config/ml.nix
          ];
        };
      };
    };
}
