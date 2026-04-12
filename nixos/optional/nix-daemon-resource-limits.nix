# Optional: cap RAM/CPU for *all* nix-daemon builds on this machine (multi-user Nix on NixOS).
# Import from a host module, e.g. `imports = [ ../../nixos/optional/nix-daemon-resource-limits.nix ];`
# Tune MemoryMax / CPUQuota so the box stays responsive during huge derivations.
{ lib, ... }:
{
  systemd.services.nix-daemon.serviceConfig = {
    MemoryHigh = lib.mkDefault "24G";
    MemoryMax = lib.mkDefault "32G";
    CPUQuota = lib.mkDefault "600%";
  };
}
