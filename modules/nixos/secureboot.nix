{
  lib,
  config,
  pkgs,
  ... }:

with lib; let
  cfg = config.my.dns;
in {
  options.my.secureboot = {
    enable = mkEnableOption "use my dns settings";
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
