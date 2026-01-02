{ config, pkgs, ... }:
{
  # Music Player Daemon
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    dataDir = "${config.home.homeDirectory}/.config/mpd";
    extraConfig = ''
      audio_output {
        type "pulse"
        name "MPD PulseAudio Output"
      }
    '';
  };

  # Music player client (rmpc)
  home.packages = with pkgs; [
    rmpc
  ];
}

