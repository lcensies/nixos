# Network / SSH session resilience (not the fix for full GUI freezes — see freeze-mitigations.nix).
{ pkgs, lib, ... }:
{
  # Idle ssh sessions often look “frozen” when NAT or middleboxes drop idle TCP; server-side
  # keepalives also help tell a dead peer from a wedged machine sooner.
  services.openssh.settings = {
    ClientAliveInterval = 60;
    ClientAliveCountMax = 6;
  };

  # Logind can still react to suspend/hibernate/lid ACPI independently of GNOME idle settings.
  services.logind.settings.Login = {
    HandleSuspendKey = "ignore";
    HandleHibernateKey = "ignore";
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # Energy Efficient Ethernet and similar link power savings have caused idle link / SSH stalls
  # on some boards; turn EEE off for wired NICs when ethtool supports it (no-op otherwise).
  systemd.services.disable-ethernet-eee = {
    description = "Disable Ethernet EEE on wired interfaces (idle SSH / link stability)";
    after = [ "network-pre.target" "systemd-udevd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for nic in /sys/class/net/*; do
        name="$(basename "$nic")"
        case "$name" in lo|docker*|veth*|br-*|virbr*|tun*|wg*) continue ;; esac
        [[ -d "$nic/wireless" ]] && continue
        ${lib.getExe pkgs.ethtool} --set-eee "$name" eee off 2>/dev/null || true
      done
    '';
  };
}
