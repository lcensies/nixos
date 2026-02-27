# Amnezia VPN client and vpn.local DNS routing via systemd-resolved.
{ ... }:
{
  programs.amnezia-vpn.enable = true;

  # Route *.vpn.local queries to the VPN interface (amn0).
  # vpnDns disabled: 172.29.172.1 may only resolve *.vpn.local; forcing it as amn0's
  # sole DNS broke general DNS when VPN was the default route. Let Amnezia set DNS.
  services.resolved.vpnDomain = {
    enable = true;
    # vpnDns = "172.29.172.1";  # Re-enable only if vpn.local resolution fails
  };
}
