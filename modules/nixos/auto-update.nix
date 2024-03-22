{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.auto-update;
in {
  options.my.auto-update = {
    enable = mkEnableOption "automatic updates";

    flake = mkOption {
      type = types.str;
      description = "flake link";
      default = "github:nikolarobottesla/infra-nix-config";
    };

  };

  config = mkIf cfg.enable {

    # Auto system update
    system.autoUpgrade = {
        enable = true;
        allowReboot = true;
        rebootWindow = {
            lower = "03:00";
            upper = "06:00";
        };
        flags = [
            "--impure"
        ];
        flake = cfg.flake;
        dates = "daily";
        randomizedDelaySec = "45min";
    };

  };
}