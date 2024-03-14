{ ... }:

{
  imports = [
    ./actualbudget.nix
    ./jellyfin.nix
    ./nextcloud.nix
    ./nginx.nix
    ./tailscale-tls.nix
  ];
}