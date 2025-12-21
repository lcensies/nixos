{ config, pkgs, ... }:
{
  # Import sing-box configuration
  imports = [
    ./sing-box.nix
    ./mullvad.nix
  ];

  boot.kernelModules = [ "tun" ];
  networking.hostName = "stable";

  # NetworkManager is enabled in gnome.nix for VPN support
  # Note: NetworkManager conflicts with wpa_supplicant, so wireless.enable is disabled
  # networking.wireless.enable = false;

  # wpa_supplicant (disabled when using NetworkManager)
  # networking.wireless.userControlled.enable = true;

  # NetworkManager configuration is in gnome.nix
  # networking.networkmanager.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";
  # networking.wireless.iwd.enable = true;

  #networking.firewall.enable = false;
  #networking.firewall.allowedUDPPorts = [...];
  #networking.firewall.allowedTCPPorts = [...];

  #networking.proxy.default = "http://user:password@proxy:port/";
  #networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  environment.systemPackages = with pkgs; [
    # WIFI tui
    impala

    dig

    
    openconnect
    openvpn
    # Well, nekoray is broken as always
    # nekoray
    # v2raya currently not used
    # amnezia-vpn
    # NetworkManager VPN support is now properly configured in gnome.nix
    # with networkmanager-l2tp and networkmanager-openvpn as plugins
  ];

  programs.amnezia-vpn.enable = true;
  # services.amnezia-vpn.enable = true;

  # Also might be required to use with sing-box
  services.resolved.enable = true;
  # programs.nekoray.tunMode.enable = true;


  # services.v2raya.enable = true; currently not used

#  services.openvpn.servers = {
#     officeVPN  = { 
#       config = '' config /home/esc2/Downloads/vpn/vpn.conf ''; 
#       updateResolvConf = true;
#     };
#   };

  #Define your networks here
  #Syntax :
  #networking.wireless.networks.Network-Name.psk = "password";

  # User networkmanager group membership is configured in gnome.nix

}
