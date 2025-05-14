{ inputs, outputs, ... }:
{
  imports = [
    # inputs.agenix.nixosModules.default
    # inputs.agenix-rekey.nixosModules.default
    inputs.catppuccin.nixosModules.catppuccin
    inputs.home-manager.nixosModules.home-manager
  ];

  # agenix / agenix-rekey
  # environment.systemPackages = [
  #   inputs.agenix.packages.${pkgs.system}.default
  #   inputs.agenix-rekey.packages.${pkgs.system}.default
  # ];

  # catppuccin/nix
  # https://nix.catppuccin.com/options/nixos-options.html
  catppuccin = {
    flavor = "frappe";
    accent = "blue";
  };

  # home-manager
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs outputs;
    };
    sharedModules = [
      inputs.catppuccin.homeManagerModules.catppuccin
      inputs.impermanence.nixosModules.home-manager.impermanence
    ];
    users.esc2.imports = [ ../../home/esc2 ];
  };
}
