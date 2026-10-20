{ lib, ... }:

let
  usb = "sdc";
  # ls -l /dev/disk/by-uuid
  usbid = "88e2f3bb-980e-46f9-adf5-f5e1064c2040";
  arrayid = "6644f36e-54c4-4d92-84f7-4ef2ab3f9a42";

  # array partition UUIDs
  uuid-map = {
    "a" = "5b4f2fff-270a-41da-968c-4bc402392891";
    "b" = "947a851a-3ca5-4c2e-8210-9b6ddcefb447";
  };
in

{
  boot.initrd.luks.devices = lib.mapAttrs (name: uuid: {
    device = "/dev/disk/by-uuid/${uuid}";
    allowDiscards = true;
    keyFile = "/key/crypted-${name}.key";
    keyFileTimeout = 10;
  }) uuid-map;

  boot.initrd.systemd.mounts = [{
    wantedBy = [ "cryptsetup-pre.target" ];
    what = "UUID=${usbid}";
    where = "/key";
    type = "ext4";
    options = "noauto";
  }];

  disko.devices = {
    disk = {
      # usb = {  # use to generate partition
      #   type = "disk";
      #   device = "/dev/${usb}";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       "${usb}1" = {
      #         size = "100%";
      #         content = {
      #           type = "filesystem";
      #           format = "ext4";
      #           mountpoint = "/key";
      #         };
      #       };
      #     };
      #   };
      # };
      os = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted-os";
                # disable settings.keyFile if you want to use interactive password entry
                settings = {
                  allowDiscards = true;
                  keyFile = "/key/crypted-os.key";  # comment in for build
                  keyFileTimeout = 10;  # initrd.systemd only
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "8G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
    nodev = {
      array0 = {
        device = "/dev/disk/by-uuid/${arrayid}";
        fsType = "btrfs";
        mountpoint = "/srv/array0";
        mountOptions = [
          "compress=zstd"
          "noatime"
        # "degraded"
        # "nofail"
        ];
      };
    };
  };
}
