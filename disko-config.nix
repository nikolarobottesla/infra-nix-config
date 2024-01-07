{
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
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "noatime" ];
                    };
                    # if you want to use timeshift, use the @s
                    # "/@" = {
                    #   mountpoint = "/";
                    #   mountOptions = [ "noatime" ];
                    # };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "noatime" ];
                    };
                    # "/@home" = {
                    #   mountpoint = "/home";
                    #   mountOptions = [ "noatime" ];
                    # };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "noatime" ];
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
  };
}
