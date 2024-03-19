# infra-nix-config
my nixos configurations, setup to use flakes

## hosts
* desktops: 15TH-TURTLE
* servers: coconut, oak
* WSL: nixos

## usage

```bash
# navigate to this folder, then (assumes host name matches flake)
sudo nixos-rebuild switch --flake '.#'

sops hosts/coconut-2/secrets.yaml 

# untested
# To switch a remote configuration, use:
NIX_SSHOPTS="-o RequestTTY=force" \
nixos-rebuild --flake .#oak-1 \
  --target-host deer@oak-1 --fast --use-remote-sudo \
  switch

# remote build and target, getting broken pipe error
NIX_SSHOPTS="-o RequestTTY=force" \
nixos-rebuild --flake .#coconut-2 \
  --build-host nixos@coconut-2 \
  --target-host nixos@coconut-2 --fast --use-remote-sudo \
  switch

```

### setup remote
1. build iso image with root ssh access
```bash
nix build .#image.oak
```
2. boot image, connect ethernet and ssh in
3. use disko to format and mount
```bash
# https://github.com/nix-community/disko/blob/master/docs/quickstart.md
nano /tmp/disko-config.nix  # paste config
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko-config.nix
```
4. comment in/modify disko-config as necessary e.g. USB disk location and keyFile usage
5. run nix config, check hardware-configuration.nix and update your build config if necessary
```bash
nixos-generate-config --no-filesystems --root /mnt
cat /mnt/etc/nixos/hardware-configuration.nix
```
6. build config for remote, copy it over and install
```bash
# To install a remote configuration, use: 
# https://github.com/NixOS/nixpkgs/issues/217891
# https://codeberg.org/kotatsuyaki/rpi4-usb-uefi-nixos-config
nixos-rebuild build --flake .#oak-1
nix-copy-closure --to root@oak result
readlink -f ./result
# returns <nix store path>
# (on remote, as root) nixos-install --system <nix store path> --root /mnt
nixos-install --system /nix/store/ndcw24fkf9m6hipqwq6x1xj9g8bmp0my-nixos-system-oak-1-23.11.20240120.1b64fc1 --root /mnt
# change root and set user password
nixos-enter  # assumes the /mnt contains the new root
passwd <user name>
```
7.  generate and add any luks keys

### setup pi
```bash
# build SDimage on a x86 box
nix build .#image.rpi4

# 1st time setup
ssh root@device
passwd nixos
su nixos
cd ~
git clone https://github.com/nikolarobottesla/infra-nix-config.git
cd infra-nix-config/
nix build .#

# on pi, build
nix build .#build.rpi4
# on pi, build and switch
sudo nixos-rebuild switch --flake '.#rpi4'
```