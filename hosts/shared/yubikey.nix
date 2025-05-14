{ pkgs, ... }:
{
  # https://nixos.wiki/wiki/Yubikey#GPG_and_SSH
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
  environment.systemPackages = with pkgs; [ yubikey-personalization ];
  services.udev.packages = with pkgs; [ yubikey-personalization ];


}
