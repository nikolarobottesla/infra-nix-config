
# nixos WSL 

## Install and 1st time setup
1. https://github.com/nix-community/NixOS-WSL
2. start wsl nixos
2. navigate to flake.nix folder
3. update cert file path as needed, only needed first time if you have the file set using `security.pki.certificateFiles` in your config
```bash
sudo NIX_SSL_CERT_FILE=/mnt/c/ProgramData/tls-ca-bundle.pem nixos-rebuild switch --flake '.#'
```
4. now you can use the rebuild switch without setting NIX_SSL_CERT_FILE


## example config
```nix
security.pki.certificateFiles = [ /mnt/c/ProgramData/tls-ca-bundle.pem ]; # path to your corporate CA bundle

nixpkgs.hostPlatform.system = "x86_64-linux";
wsl.enable = true;
wsl.defaultUser = "nixos";

```

## notes
* tried these first, not needed for nix, may fix other package managers?
```bash
export SSL_CERT_FILE=/mnt/c/ProgramData/tls-ca-bundle.pem
export NIX_SSL_CERT_FILE=/mnt/c/ProgramData/tls-ca-bundle.pem
```