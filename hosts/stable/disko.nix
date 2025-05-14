let
  device = "/dev/nvme0n1";
in
{
  disko.devices = {
    disk.main = {
      inherit device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "defaults" ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
                # https://nixos.wiki/wiki/Full_Disk_Encryption#Option_2:_Copy_Key_as_file_onto_a_vfat_usb_stick
                # https://github.com/reo101/rix101/blob/a6efd4146bbe0c7fb44343225b9dbf9585472597/machines/nixos/x86_64-linux/jeeves/disko.nix#L94-L107
              };
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  # https://github.com/nix-community/impermanence#btrfs-subvolumes
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                  };
                  "/opt" = {
                    mountpoint = "/opt";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
}
