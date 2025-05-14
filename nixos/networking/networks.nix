{config, pkgs, ...}:
{
  networking.hostName = "stable";


  # networking.wireless.enable = true;
  
  
  # wpa_supplicant
  networking.wireless.userControlled.enable = true;

  # networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;

  #networking.firewall.enable = false;
  #networking.firewall.allowedUDPPorts = [...];
  #networking.firewall.allowedTCPPorts = [...];

  #networking.proxy.default = "http://user:password@proxy:port/";
  #networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  environment.systemPackages = with pkgs; [
    # WIFI tui
    unstable.impala

    openconnect
    nekoray
    v2raya
  ];

  services.v2raya.enable = true;


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
