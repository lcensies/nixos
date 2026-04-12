# Full-system hangs (frozen cursor / dead mouse, not just dropped SSH) on this host.
#
# Common causes here: (1) compositor + proprietary NVIDIA on Wayland, (2) deepest CPU C-states
# on older Intel servers/workstations, (3) rarer: NVMe/firmware — use `journalctl` / `dmesg` after reboot.
#
# Next freeze — quick check: Ctrl+Alt+F3 to a text VT. If VT works, the kernel is alive → likely GPU /
# GNOME/compositor. If the whole machine is dead, note whether fans/disk LED still react; consider RAM
# / PSU / thermals as well as drivers.
#
# To prefer Wayland again (e.g. after driver updates), remove the GDM line below or set wayland = true.
{ lib, ... }:
{
  # GNOME on Xorg is still the least drama with the NVIDIA proprietary stack for many setups.
  services.displayManager.gdm.wayland = lib.mkForce false;

  # Avoid rare “idle” hard lockups on Haswell-EP–era Xeon by skipping the deepest idle states.
  boot.kernelParams = [ "intel_idle.max_cstate=1" ];
}
