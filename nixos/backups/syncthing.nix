{ pkgs, ... }:
{
  home.packages = [ pkgs.syncthing ];

  systemd.user.services.syncthing = {
    Unit = {
      Description = "Syncthing - Open Source Continuous File Synchronization";
      Documentation = "man:syncthing(1)";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.syncthing}/bin/syncthing serve --config=/home/esc2/.config/syncthing --data=/home/esc2/.local/share/syncthing --no-browser --no-restart";
      Restart = "on-failure";
      RestartSec = 5;
      SuccessExitStatus = [ "0" "2" ];
      TimeoutStopSec = 5;
      KillMode = "mixed";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

}
