{ lib, ... }:

let
  usb = "sdc";
  usbid = "88e2f3bb-980e-46f9-adf5-f5e1064c2040";
  arrayid = "6644f36e-54c4-4d92-84f7-4ef2ab3f9a42";
  mountUsb = ''
    mkdir -m 0755 -p /key
    sleep 2 # To make sure the usb key has been loaded
    mount -n -t ext4 -o ro `findfs UUID=${usbid}` /key
  '';
  array-disks = lib.genAttrs [ "a" "b" ] (name: {
    type = "disk";
    device = "/dev/sd${name}";
    content = {
      type = "gpt";
      partitions = {
        "luks-sd${name}" = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypted-${name}";
            # disable settings.keyFile if you want to use interactive password entry           
            settings = {
              allowDiscards = true;
              fallbackToPassword = true;
              keyFile = "/key/crypted-${name}.key";  # comment in for build
              preOpenCommands = mountUsb;
            };
          };
        };
      };
    };
  });
in

{
  # wasn't able to get systemd version working, didn't prompt for password, even when keyFileTimeout was set
  # use the systemd initrd, this is needed  to use the luks keyFileTimeout option
  # boot.initrd.systemd.enable = true;

  # boot.initrd.systemd.mounts = [{
  #   what = "UUID=${usbid}";
  #   where = "/key";
  #   type = "ext4";
  # }];

  disko.devices = {
    disk = {
      # usb = {  # use to generate partition
      #   type = "disk";
      #   device = "${usb}";
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
                  fallbackToPassword = true;
                  keyFile = "/key/crypted-os.key";  # comment in for build
                  # keyFileTimeout = 10;  # initrd.systemd only
                  preOpenCommands = mountUsb;
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
      a = array-disks.a;
      b = array-disks.b;
    };
    nodev = {
      array0 = {
        device = "/dev/disk/by-uuid/${arrayid}";
        fsType = "btrfs";
        mountpoint = "/mnt/array0";
        mountOptions = [ "compress=zstd" "noatime" ];
      };
    };
  };
}
