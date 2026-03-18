# macos 

## setup
1. installed homebrew using self service! - nix-homebrew didn't work, try not installing homebrew or turn off auto migration
1. install nix using https://github.com/DeterminateSystems/nix-installer - tried lix but had HTTPS errors
1. (optional) initialize a flake to check for new defaults including system.stateVersion
```bash
nix flake init -t nix-darwin
```
2. install nix-darwin, might need to run again after developer tools are installed

```bash
# first time
sudo bash -c '. /etc/profile; nix run nix-darwin -- switch --flake '.#''
# attempted with lix but still didn't resolve HTTPS errors
#sudo bash -c '. /etc/profile; export NIX_SSL_CERT_FILE=~/tls-ca-bundle.crt; nix run nix-darwin -- switch --flake '.#''

# rebuild
darwin-rebuild switch --flake '.#'

```
3. install xcode developer tools when prompted

4. fix brew paths if needed
https://stackoverflow.com/questions/14527521/brew-doctor-says-warning-usr-local-include-isnt-writable

```zsh
sudo chown -R $(whoami) $(brew --prefix)/*
```

5. install conda
```zsh
curl -fsSLo Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-$(uname -m).sh"
bash Miniforge3.sh -b -p "${HOME}/conda"
source "${HOME}/conda/etc/profile.d/conda.sh"
conda init
conda init zsh
```

6. init and start podman
https://podman.io/docs/installation
```zsh
podman machine init
podman machine start
```
