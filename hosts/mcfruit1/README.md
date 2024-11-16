# macos 

## setup
1. install nix using https://github.com/DeterminateSystems/nix-installer
1. (optional) initialize a flake to check for new defaults including system.stateVersion
```bash
nix flake init -t nix-darwin
```
2. install nix-darwin, might need to run again after developer tools are installed

```bash
# first time
nix run nix-darwin -- switch --flake '.#'

# rebuild
darwin-rebuild switch --flake '.#'

```
3. install xcode developer tools when prompted

4. fix brew paths if needed
https://stackoverflow.com/questions/14527521/brew-doctor-says-warning-usr-local-include-isnt-writable

```zsh
sudo chown -R $(whoami) $(brew --prefix)/*
```

5. init and start podman
https://podman.io/docs/installation
```zsh
podman machine init
podman machine start
```
