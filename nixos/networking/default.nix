{config, pkgs, ...}:
{
  boot.kernelModules = [ "tun" ];
  networking.hostName = "stable";


  # networking.wireless.enable = true;
  
  
  # wpa_supplicant
  networking.wireless.userControlled.enable = true;

  # Enable NetworkManager for VPN support
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;
  


  #networking.firewall.enable = false;
  #networking.firewall.allowedUDPPorts = [...];
  #networking.firewall.allowedTCPPorts = [...];

  #networking.proxy.default = "http://user:password@proxy:port/";
  #networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  environment.systemPackages = with pkgs; [
    # WIFI tui
    impala

    openconnect
    openvpn
    nekoray
    # v2raya currently not used
    
    # NetworkManager VPN support
    networkmanager-openvpn
  ];

  # services.v2raya.enable = true; currently not used

  # sing-box with TUN inbound; read external JSON config, not tracked in git
  # services.sing-box = {
  #   enable = true;
  #   settings = {};
  # };

  # Route system traffic via local proxy defaults
  # environment.variables = {
  #   http_proxy = "http://127.0.0.1:7890";
  #   https_proxy = "http://127.0.0.1:7890";
  #   HTTP_PROXY = "http://127.0.0.1:7890";
  #   HTTPS_PROXY = "http://127.0.0.1:7890";
  #   no_proxy = "127.0.0.1,localhost,.local,.lan";
  #   NO_PROXY = "127.0.0.1,localhost,.local,.lan";
  # };

  # Allow deprecated special outbounds (dns) until we migrate rules fully
  systemd.services."sing-box".environment = {
    ENABLE_DEPRECATED_SPECIAL_OUTBOUNDS = "true";
  };

  # Force sing-box to load config from /etc/sing-box/config.json instead of Nix settings
  systemd.services."sing-box".serviceConfig.ExecStart = pkgs.lib.mkForce [
    ""
    "${pkgs.sing-box}/bin/sing-box run -c /etc/sing-box/config.json"
  ];

  # Allow traffic via TUN interface
  networking.firewall.trustedInterfaces = [ "tun0" ];



  security.sudo.extraRules = [{
      groups = [ "wheel" ]; 
      commands = [ 
       {
         command = "/run/current-system/sw/bin/nekoray";
         options = ["NOPASSWD" "SETENV"];
       }
      ]; 
  }];

  #Define your networks here
  #Syntax : 
  #networking.wireless.networks.Network-Name.psk = "password";
  
  # users.users.esc2.extraGroups = [ "networkmanager" ];
  
}
