{ lib, ... }:
{
  # https://nixos.wiki/wiki/PipeWire
  hardware.pulseaudio.enable = lib.mkForce false;
  security.rtkit.enable = true;
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.alsa.support32Bit = true;
  services.pipewire.pulse.enable = true;

  # services.pipewire.wireplumber.enable = true;
  # ".local/state/wireplumber"
}
