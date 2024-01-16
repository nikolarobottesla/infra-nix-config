# infra-nix-config
my nixos configurations, setup to use flakes

## machine types
* workstation.nix
* pi-server.nix

## usage

### pi
```bash
# build SDimage on a x86 box
nix build .#images.rpi4

# on pi, build
nix build .#builds.rpi4
# on pi, build and switch
sudo nixos-rebuild switch --flake '.#rpi4'
```