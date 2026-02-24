# Route DNS queries for vpn.local to the VPN interface (amn0) in systemd-resolved.
# When amn0 is up (VPN connected), queries for *.vpn.local are sent to the DNS
# server(s) associated with that interface. Re-applies when the interface appears
# or changes (udev) and at boot.
#
# Refs: resolvectl(1), systemd-resolved(8); NixOS options services.resolved.*

{ config, lib, pkgs, ... }:

let
  vpnInterface = "amn0";
  vpnDomain = "vpn.local";
  # Script with optional VPN DNS injection (when config option is set)
  scriptWithDns = pkgs.writeShellScript "resolved-vpn-domain-with-dns" (
    let
      dnsLine = if (config.services.resolved.vpnDomain != null && config.services.resolved.vpnDomain.vpnDns != null)
        then "${pkgs.systemd}/bin/resolvectl dns ${vpnInterface} ${lib.escapeShellArg config.services.resolved.vpnDomain.vpnDns}"
        else "";
    in
      ''
        set -e
        if [ ! -d /sys/class/net/${vpnInterface} ]; then
          exit 0
        fi
        ${pkgs.systemd}/bin/resolvectl domain ${vpnInterface} ${vpnDomain}
        ${dnsLine}
      ''
  );
in
{
  options.services.resolved.vpnDomain = lib.mkOption {
    type = lib.types.nullOr (lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "route vpn.local to VPN interface amn0 in systemd-resolved";
        vpnDns = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Optional DNS server IP for amn0 (use if VPN client does not register DNS with resolved).";
        };
      };
    });
    default = null;
    description = "Route the domain vpn.local to the VPN interface amn0 when it is up.";
  };

  config = lib.mkIf (config.services.resolved.enable && config.services.resolved.vpnDomain != null && config.services.resolved.vpnDomain.enable) {
    systemd.services.resolved-vpn-domain = {
      description = "Route vpn.local to VPN interface (amn0) in systemd-resolved";
      after = [ "systemd-resolved.service" "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${scriptWithDns}";
      };
      wantedBy = [ "multi-user.target" ];
    };

    services.udev.extraRules = ''
      # When VPN interface amn0 appears or changes, re-apply vpn.local routing in resolved
      SUBSYSTEM=="net", KERNEL=="${vpnInterface}", ACTION=="add", TAG+="systemd", ENV{SYSTEMD_WANTS}="resolved-vpn-domain.service"
      SUBSYSTEM=="net", KERNEL=="${vpnInterface}", ACTION=="change", TAG+="systemd", ENV{SYSTEMD_WANTS}="resolved-vpn-domain.service"
    '';
  };
}
