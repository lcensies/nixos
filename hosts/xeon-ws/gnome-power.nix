# Workstation: no automatic screen blank / suspend (GNOME + systemd-logind).
# logind idle is separate from the logged-in GNOME session (and from GDM autoSuspend=false).
{ ... }:
{
  services.logind.settings.Login = {
    IdleAction = "ignore";
    IdleActionSec = "infinity";
  };

  home-manager.users.esc2 =
    { lib, ... }:
    {
      dconf.settings = {
        "org/gnome/desktop/session" = {
          idle-delay = lib.hm.gvariant.mkUint32 0;
        };
        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "nothing";
          sleep-inactive-battery-type = "nothing";
          sleep-inactive-ac-timeout = lib.hm.gvariant.mkInt32 0;
          sleep-inactive-battery-timeout = lib.hm.gvariant.mkInt32 0;
        };
      };
    };
}
