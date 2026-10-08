{
  # for the final mount
  fileSystems."/boot".options = [ "fmask=0077" "dmask=0077" ];

  boot.initrd.kernelModules = [ "vfat" "nls_cp437" "nls_iso8859-1"];
  boot.initrd.systemd.mounts = [{
    wantedBy = [ "cryptsetup-pre.target" ];
    what = "/dev/disk/by-partlabel/disk-vdb-ESP";
    where = "/boot";
    type = "vfat";
    options = "fmask=0077,dmask=0077";
  }];

  disko.devices = {
    disk = {
      vdb = {
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
                name = "crypted";
                # disable settings.keyFile if you want to use interactive password entry
                #passwordFile = "/tmp/secret.key"; # Interactive
                settings = {
                  allowDiscards = true;
                  keyFile = "/boot/keys/crypted-os.key";  # comment in for build
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
                    # if you want to use timeshift, use the @s
                    # "/@" = {
                    #   mountpoint = "/";
                    #   mountOptions = [ "compress=zstd" "noatime" ];
                    # };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    # "/@home" = {
                    #   mountpoint = "/home";
                    #   mountOptions = [ "compress=zstd" "noatime" ];
                    # };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "32G";
                    };
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
