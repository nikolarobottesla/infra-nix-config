{ config,
  lib,
  pkgs,
  ... }:
{
    imports = [
    # ./desktop.nix
    ./opencode.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}