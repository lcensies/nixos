{ config, pkgs, ... }:
{
  # Allow deprecated special outbounds (dns) until we migrate rules fully
  services.sing-box = {
    enable = false;  # Disable the default service
  };

  systemd.services.sing-box = {
    enable = true;
    description = "sing-box service";
    documentation = [ "https://sing-box.sagernet.org" ];
    after = [ "network.target" "nss-lookup.target" "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      StateDirectory = "sing-box";
      CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH";
      AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH";
      ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /etc/sing-box/config.json";
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      Restart = "on-failure";
      RestartSec = "10s";
      Environment = [
        "ENABLE_DEPRECATED_SPECIAL_OUTBOUNDS=true"
      ];
    };
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
  networking.firewall.trustedInterfaces = [ "tun10" ];

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
