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