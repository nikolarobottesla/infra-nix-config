# steam on nixos-apple-silicon

check here to see if there are updates
https://github.com/nix-community/nixos-apple-silicon/issues/237#issuecomment-3419982934

Build the Docker image locally:
```bash
docker build Distrobox/steam/Dockerfile --tag steam:latest
```

Create the Distrobox container:
```bash
mkdir -p ~/Distrobox/steam
distrobox-create --name steam --image steam:latest --home ~/Distrobox/steam
```

Enter the Distrobox container and start Steam:
```bash
# enter container
distrobox enter steam

# start steam (host desktop = plasma 6)
unset QT_PLUGIN_PATH
unset QML2_IMPORT_PATH
PATH="/bin:$PATH" LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH steam
```