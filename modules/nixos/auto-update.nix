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
        enable = lib.mkDefault true;
        allowReboot = true;
        dates = "02:00";  # every day at 2AM
        flags = cfg.flags;
        flake = cfg.flake;
        operation = lib.mkDefault "boot";
        persistent = true; # Ensures missed upgrades execute immediately on boot
        randomizedDelaySec = "45min";
        # rebuild needs to complete within the reboot window to reboot
        rebootWindow = {
            lower = "02:00";
            upper = "06:00";
        };
    };

    # Prevent auto-upgrade failures due to early-boot network absence
    systemd.services.nixos-upgrade = {
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "60"; # Wait 1 minute before retrying
      };
      unitConfig = {
        StartLimitIntervalSec = 600;
        StartLimitBurst = 3; # Allow 3 attempts within 10 minutes
      };
    };
  };
}
