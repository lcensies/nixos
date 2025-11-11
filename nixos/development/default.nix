{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # jetbrains.rust-rover  # Installed via flatpak instead
  ];
}
