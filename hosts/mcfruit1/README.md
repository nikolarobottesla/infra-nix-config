# macos 

## setup
1. install nix using https://github.com/DeterminateSystems/nix-installer
2. install nix-darwin, might need to run again after developer tools are installed

```bash
# first time
nix run nix-darwin -- switch --flake '.#'

# rebuild
darwin-rebuild switch --flake '.#'

```
3. install xcode developer tools when prompted
