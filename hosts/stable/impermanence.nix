{ inputs
, config
, lib
, ...
}:
let
  # mtime = "30"; # monthly
  mtime = "7"; # weekly
  # mtime = "1"; # daily
in
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  # https://github.com/nix-community/impermanence#btrfs-subvolumes
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount /dev/mapper/cryptroot /btrfs_tmp

    if [[ -e /btrfs_tmp/root ]]; then
      mkdir -p /btrfs_tmp/old_roots
      timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
      mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
      IFS=$'\n'
      for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
        echo "removing $i ..."
        delete_subvolume_recursively "/btrfs_tmp/$i"
      done
      btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +${mtime}); do
      delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';

  environment.persistence."/persist" = {
    hideMounts = true;
    # https://nixos.wiki/wiki/Impermanence#Persisting
    directories =
      [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/tmp"
      ]
      ++ lib.optional config.hardware.bluetooth.enable "/var/lib/bluetooth"
      ++ lib.optional config.networking.wireless.iwd.enable "/var/lib/iwd"
      ++ lib.optional config.networking.networkmanager.enable "/etc/NetworkManager/system-connections";
    files = [ "/etc/machine-id" ];
  };
  programs.fuse.userAllowOther = true;
}
