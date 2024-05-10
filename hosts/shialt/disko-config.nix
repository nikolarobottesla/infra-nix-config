# dd if=/dev/sdb2 of=/dev/nvme1n1p2 bs=1M status=progress
# resized using gparted
# unencrypted
# do 'check' operation
# transfer partition names and flags
# close encryption
# sudo cryptsetup open /dev/nvme1n1p2 crypted
# sudo mount /dev/mapper/crypted /mnt/ -o compress=zstd -o noatime -o subvol=/root -o X-mount.mkdir
# sudo mount /dev/mapper/crypted /mnt/.swapvol -o defaults -o subvol=/swap -o X-mount.mkdir
# sudo mount /dev/disk/by-partlabel/disk-vdb-ESP /mnt/boot -t vfat -o defaults -o X-mount.mkdir
# sudo mount /dev/mapper/crypted /mnt/home -o compress=zstd -o noatime -o subvol=/home -o X-mount.mkdir
# sudo mount /dev/mapper/crypted /mnt/nix -o compress=zstd -o noatime -o subvol=/nix -o X-mount.mkdir
# sudo nixos-generate-config --no-filesystems --root /mnt
{
  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = "/dev/nvme1n1";
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
  };
}
