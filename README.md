# infra-nix-config
my nixos configurations, setup to use flakes

## machine types
* workstation.nix
* pi-server.nix

## usage

```bash
# navigate to this folder, then
sudo nixos-rebuild switch --flake '.#'

# build iso image
nix build .#image.oak

# To switch a remote configuration, use: 
nixos-rebuild --flake .#mymachine \
  --target-host mymachine-hostname --build-host mymachine-hostname --fast \
  switch

# To install a remote configuration, use: 
# https://github.com/NixOS/nixpkgs/issues/217891
# https://codeberg.org/kotatsuyaki/rpi4-usb-uefi-nixos-config
nixos-rebuild build --flake .#oak-1
nix-copy-closure --to root@oak result
readlink -f ./result
# returns <nix store path>
# (on remote, as root) nixos-install --system <nix store path> --root /mnt
nixos-install --system /nix/store/m31q5c....64fc1 --root /mnt
# change root and set user password
nixos-enter  # assumes the /mnt contains the new root
passwd <user name>
```

### pi
```bash
# build SDimage on a x86 box
nix build .#image.rpi4

# on pi, build
nix build .#build.rpi4
# on pi, build and switch
sudo nixos-rebuild switch --flake '.#rpi4'
```