{ ... }:

{
  imports = [
    ./actualbudget.nix
    ./nextcloud.nix
    ./nginx.nix
    ./tailscale-tls.nix
  ];
}