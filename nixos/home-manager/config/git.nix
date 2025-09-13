{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "esc2";
    userEmail = "esc2@proton.me";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
