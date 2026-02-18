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
    in
    {
      #packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
      # overlays = import ./overlays { inherit inputs; };
      # nixosModules = import ./modules/nixos;

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
              ./hosts/thinkbook14
              ./nixos/home-manager # Fixed fcitx5 issue with package override
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

        };

      homeConfigurations = {
        "esc2" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            ./nixos/home-manager/home.nix
            ./nixos/home-manager/config/ml.nix
          ];
        };
      };
    };
}
