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

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    # `import ./.` / legacy nix-build (deploy-rs when flake detection fails); non-flake input
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    # LazyVim via nixvim; build uses `neovimOverlay` + makeNixvimWithModule { pkgs = ... } (not path subflakes)
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.inputs.flake-parts.follows = "flake-parts";

    # Plain rcm tree (see rcm(7)); symlinked to ~/.dotfiles + rcup on HM activation
    dotfiles = {
      url = "github:lcensies/dotfiles";
      flake = false;
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      impermanence,
      home-manager,
      deploy-rs,
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

      lazyvimNvimFor = system: let
        pkgs = nixpkgs.legacyPackages.${system}.extend (neovimOverlay nixpkgs.outPath);
        nixvim' = inputs.nixvim.legacyPackages.${system};
        module = import ./nixos/vim/lazyvim-nixvim-config.nix { inherit pkgs; lib = pkgs.lib; };
      in
      nixvim'.makeNixvimWithModule { inherit pkgs module; };
    in
    {
      #packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      packages = forAllSystems (system: {
        nvim-lazyvim = lazyvimNvimFor system;
      });

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

      # https://github.com/serokell/deploy-rs — build on the machine running `deploy` (see remoteBuild).
      deploy.nodes.xeon-ws = {
        hostname = "192.168.31.3";
        sshUser = "esc2";
        remoteBuild = false;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.xeon-ws;
        };
      };

      checks = builtins.mapAttrs (
        system: deployLib: deployLib.deployChecks self.deploy
      ) deploy-rs.lib;

      apps = forAllSystems (system: {
        deploy-rs = {
          type = "app";
          program = "${inputs.deploy-rs.packages.${system}.default}/bin/deploy";
        };
      });

      homeConfigurations = {
        "esc2" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux.extend inputs.nur.overlays.default;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            ./nixos/home-manager/home.nix
            ./nixos/home-manager/config/ml.nix
            ./nixos/home-manager/config/dotfiles.nix
          ];
        };
      };
    };
}
