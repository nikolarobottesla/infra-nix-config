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
      pkiBundle = "/etc/secureboot";
    };

  };
}
