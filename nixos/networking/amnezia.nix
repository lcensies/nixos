# Amnezia VPN client and vpn.local DNS routing via systemd-resolved.
{ ... }:
{
  programs.amnezia-vpn.enable = true;

  # Route *.vpn.local queries to the CoreDNS instance on the VPN server.
  # 172.29.172.1 is the VPN interface IP of the server (VPN_BIND_IP).
  services.resolved.vpnDomain = {
    enable = true;
    vpnDns = "172.29.172.1";
  };
}
