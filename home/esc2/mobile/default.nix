{
  imports = [
    ../../shared
    ../../shared/features/audio
    ../../shared/features/cli/mobile
    ../../shared/features/mobile
    ../programs/git.nix
    ../programs/yubikey.nix
    ./gpg.nix
  ];

  home.username = "esc2";
  home.homeDirectory = "/home/esc2";

  home.file.".face".source = ../../../assets/100897044_p0.png;
}
