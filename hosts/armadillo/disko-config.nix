{
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-APPLE_SSD_AP1024R_0ba016eae3245a0e";
        destroy = false;

        content = {
          type = "gpt";
          partitions = {
            iBootSystemContainer = {
              label = "iBootSystemContainer";
              priority = 1;
              type = "AF0B";
              uuid = "0324fdea-762e-4c5d-af96-3910edcbd508";
            };

            Container = {
              label = "Container";
              priority = 2;
              type = "AF0A";
              uuid = "3dfbbb9a-f92a-429d-9652-0725ce1fda8d";
            };

            NixOSContainer = {
              priority = 3;
              type = "AF0A";
              uuid = "b1d41983-abb6-4f13-a575-3f2589f8f68f";
            };

            ESP = {
              uuid = "3898a948-ef3d-4114-af58-e502b89fcaaa";
              priority = 4;
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            RecoveryOSContainer = {
              label = "RecoveryOSContainer";
              priority = 5;
              type = "AF0C";
              uuid = "43e5b073-c2c9-412a-abfc-b7d2b287644b";
            };

            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings = {
                  allowDiscards = true;
                };
                extraFormatArgs = [ "--pbkdf argon2id" ];
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    # "/swap" = {
                    #   mountpoint = "/swap";
                    #   swap.swapfile.size = "16G";
                    # };
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
