{
  config,
  inputs,
  lib,
  pkgs,
  ... }:

with lib; let
  cfg = config.my.secureboot;
in {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];
  
  options.my.secureboot = {
    enable = mkEnableOption "use secureboot";
  };

  config = mkIf cfg.enable {

    # Lanzaboote currently replaces the systemd-boot module.
    # This setting is usually set to true in configuration.nix
    # generated at installation time. So we force it to false
    # for now.
    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      # This error: 'Get stub name: No such file or directory (os error 2)'
      # means you need to migrate your keys: 'sbctl setup --migrate'
      pkiBundle = "/var/lib/sbctl";
    };

  };
}
