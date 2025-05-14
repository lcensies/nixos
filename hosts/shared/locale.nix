{ lib, options, ... }:
{
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    # extraLocaleSettings = {
    #   LC_TIME = lib.mkDefault "zh_CN.UTF-8";
    # };
    supportedLocales = lib.mkDefault [
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
  };
  time.timeZone = lib.mkDefault "Europe/Moscow";

  # use ntpd-rs instead of systemd-timesyncd
  services.timesyncd.enable = false;
  services.ntpd-rs.enable = true;
  services.ntpd-rs.useNetworkingTimeServers = true;
  # https://nixos.wiki/wiki/NTP
}
