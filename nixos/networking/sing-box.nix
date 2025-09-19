{ config, pkgs, ... }:
{
  # Allow deprecated special outbounds (dns) until we migrate rules fully
  services.sing-box = {
    enable = true;
  };

  systemd.services.sing-box.serviceConfig = {
    Environment = [
      "ENABLE_DEPRECATED_SPECIAL_OUTBOUNDS=true"
    ];
  };

  environment.variables = {
    http_proxy = "http://127.0.0.1:7890";
    https_proxy = "http://127.0.0.1:7890";
    HTTP_PROXY = "http://127.0.0.1:7890";
    HTTPS_PROXY = "http://127.0.0.1:7890";
    no_proxy = "127.0.0.1,localhost,.local,.lan";
    NO_PROXY = "127.0.0.1,localhost,.local,.lan";
  };


  # Force sing-box to load config from /etc/sing-box/config.json instead of Nix settings

  # Allow traffic via TUN interface
  networking.firewall.trustedInterfaces = [ "tun0" ];

  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nekoray";
          options = [
            "NOPASSWD"
            "SETENV"
          ];
        }
      ];
    }
  ];
}
