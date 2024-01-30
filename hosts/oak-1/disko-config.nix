{ lib, ... }:

let
  usb = "sdd";
  usbid = "88e2f3bb-980e-46f9-adf5-f5e1064c2040";
#   array-disks = lib.genAttrs [ "a" "b" ] (name: {
#     type = "disk";
#     device = "/dev/sd${name}";
#     content = {
#       type = "gpt";
#       partitions = {
#         "luks-sd${name}" = {
#           size = "100%";
#           content = {
#             type = "luks";
#             name = "crypted-${name}";
#             # disable settings.keyFile if you want to use interactive password entry           
#             settings = {
#               # keyFile = "/key/crypted-${name}.key";  # comment in for build
#               allowDiscards = true;
#             };
#             content = {
#               type = "btrfs";
#               extraArgs = [ "-f" ];
#               subvolumes = {
#                 "/sd${name}-data" = {
#                   mountpoint = "/mnt/sd${name}-data";
#                   mountOptions = [ "compress=zstd" "noatime" ];
#                 };
#               };
#             };
#           };
#         };
#       };
#     };
#   });
in

{
  # use the systemd initrd, this is needed  to use the luks keyFileTimeout option
  boot.initrd.systemd.enable = true;

  # when using systemd initrd this should mount the key device in /dev/mapper/
  # key device needs to be a luks type? 
  boot.initrd.luks.devices."key" = {
    device = "/dev/disk/by-uuid/${usbid}";
  };

  disko.devices = {
    disk = {
      # usb = {
      #   type = "disk";
      #   # device = "usb-key";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       "/dev/disk/by-uuid/${usbid}" = {
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
                  # fallbackToPassword = true;
                  keyFile = "/key/crypted-os.key";  # comment in for build
                  keyFileTimeout = 5;
                  # preLVM = false;
                  # preOpenCommands = ''
                  #   mkdir -m 0755 -p /key
                  #   sleep 2 # To make sure the usb key has been loaded
                  #   mount -n -t ext4 -o ro `findfs UUID=${usbid}` /key
                  # '';
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
      # a = array-disks.a;
      # b = array-disks.b;
    };
  };
}
