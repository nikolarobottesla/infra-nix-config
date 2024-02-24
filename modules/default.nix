{ ... }:

{
  imports = [
    ./nextcloud.nix
    ./nginx.nix
    ./tailscale-tls.nix
  ];
}