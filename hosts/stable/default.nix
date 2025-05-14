{ inputs, ... }:
{
  imports = [
    ../shared
    ../shared/features/desktop/common
    ../shared/features/desktop/gnome
    ../shared/features/virtualisation
    ../shared/users/esc2
    inputs.chaotic.nixosModules.default
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./impermanence.nix
    ./hardware.nix
    ./services.nix
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.loader.systemd-boot.enable = true;
  # boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "stable";
  networking.wireless.iwd.enable = true;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  # users.mutableUsers = false;
  # FIXME: update password
  # users.users.root.initialPassword = "correcthorsebatterystaple";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
