{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    jetbrains.rust-rover
  ];
}
