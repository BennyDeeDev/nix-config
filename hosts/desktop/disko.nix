# Disk layout for Samsung SSD 990 PRO with Heatsink 1TB (serial S7HFNJ0Y704719Z)
# Device identified by serial to survive NVMe enumeration changes
{ ... }:

{
  disko.devices = {
    disk = {
      games = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_1TB_S7HDNJ0Y413952T";
        content = {
          type = "gpt";
          partitions.games = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "btrfs";
              extraArgs = [
                "-L"
                "Games"
              ];
              mountpoint = "/mnt/games";
              mountOptions = [
                "compress=zstd"
                "noatime"
                "discard=async"
                "X-mount.owner=benjamin"
                "X-mount.group=users"
                "X-mount.mode=0775"
              ];
            };
          };
        };
      };
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_with_Heatsink_1TB_S7HFNJ0Y704719Z";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "discard=async"
                    ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "discard=async"
                    ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "discard=async"
                    ];
                  };
                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "discard=async"
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
}
