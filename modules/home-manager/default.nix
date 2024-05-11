{ config,
  lib,
  pkgs,
  ... }:
{
    imports = [
    # ./desktop.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}