# https://rossabaker.com/configs/podman/
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cromulent.services.podman;

  # Work around https://github.com/containers/podman/issues/17026
  # by downgrading to qemu-8.1.3.
  inherit
    (import (pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "4db6d0ab3a62ea7149386a40eb23d1bd4f508e6e";
      sha256 = "sha256-kyw7744auSe+BdkLwFGyGbOHqxdE3p2hO6cw7KRLflw=";
    }) {inherit (pkgs) system;})
    qemu
    ;

  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
in {
  options.cromulent.services.podman = {
    enabled =
      mkEnableOption "Podman"
      // {
        default = false;
      };
  };

  config = mkIf cfg.enabled {
    environment.systemPackages = [
      pkgs.podman
      pkgs.podman-compose
      pkgs.podman-desktop
      qemu
      pkgs.xz
    ];

    # https://github.com/containers/podman/issues/17026
    environment.pathsToLink = ["/share/qemu"];

    # https://github.com/LnL7/nix-darwin/issues/432#issuecomment-1024951660
    environment.etc."containers/containers.conf.d/99-gvproxy-path.conf".text = ''
      [engine]
      helper_binaries_dir = ["${pkgs.gvproxy}/bin"]
    '';
  };
}
