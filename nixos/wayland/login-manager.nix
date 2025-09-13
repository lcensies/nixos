{ config, pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.sway}/bin/sway";
        user = "esc2";
      };
      default_session = initial_session;
    };
  };
}
