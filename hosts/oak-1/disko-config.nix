{ lib, ... }:

let
  usb = "sdc";
  # ls -l /dev/disk/by-uuid
  usbid = "88e2f3bb-980e-46f9-adf5-f5e1064c2040";
  arrayid = "6644f36e-54c4-4d92-84f7-4ef2ab3f9a42";
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
              # fallbackToPassword = true; # not able to build when set, error: "implied by systemd stage 1"
              keyFile = "/key/crypted-${name}.key";  # comment in for build
              keyFileTimeout = 10;  # initrd.systemd only
            };
          };
        };
      };
    };
  });
in

{

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
      a = array-disks.a;
      b = array-disks.b;
    };
    nodev = {
      array0 = {
        device = "/dev/disk/by-uuid/${arrayid}";
        fsType = "btrfs";
        mountpoint = "/srv/array0";
        mountOptions = [ "compress=zstd" "noatime" ];
      };
    };
  };
}
