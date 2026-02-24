{ ... }:
{
  # Reachable at http://syncthing.local:8384
  networking.hosts = {
    "127.0.0.1" = [ "syncthing.local" ];
  };
}
