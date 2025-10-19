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

    flags = mkOption {
      type = types.listOf types.str;
      description = ''list of flags example:
        [
          "--impure"
        ];
      '';
      default = [];
    };

  };

  config = mkIf cfg.enable {

    # Auto system update
    system.autoUpgrade = {
        enable = true;
        allowReboot = true;
        dates = "02:00";  # every day at 2AM
        flags = cfg.flags;
        flake = cfg.flake;
        operation = lib.mkDefault "boot";
        randomizedDelaySec = "45min";
        # rebuild needs to complete within the reboot window to reboot
        rebootWindow = {
            lower = "02:00";
            upper = "06:00";
        };
    };

  };
}