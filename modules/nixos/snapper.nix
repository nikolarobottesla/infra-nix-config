{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.snapper;
in {
  options.my.snapper = {
    enable = mkEnableOption "automatic updates";

    subvolume = mkOption {
      type = types.str;
      description = "subvolume";
      default = "home";
    };

    user = mkOption {
      type = types.str;
      description = "username";
    };

  };

  config = mkIf cfg.enable {

    systemd.services."create-btrfs-subvolume-in-${cfg.subvolume}" = {
      description = "Create Btrfs Subvolume in  ${cfg.subvolume}";
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        btrfs-progs
        coreutils
      ];
      # must use script to get path, execStart does not use path
      script = ''
        if [ ! -d "/${cfg.subvolume}/.snapshots" ]; then
          btrfs subvolume create /${cfg.subvolume}/.snapshots;
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };

    # enable snapper (btrfs snapshots)
    services.snapper =  {
      snapshotInterval = "hourly";
      cleanupInterval = "1d";
      configs."${cfg.subvolume}" = {
        SUBVOLUME = "/${cfg.subvolume}";
        ALLOW_USERS = [ cfg.user ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_MIN_AGE="1800";
        TIMELINE_LIMIT_HOURLY="0";
        TIMELINE_LIMIT_DAILY="3";
        TIMELINE_LIMIT_WEEKLY="1";
        TIMELINE_LIMIT_MONTHLY="1";
        TIMELINE_LIMIT_YEARLY="1";
      };
    };
  };
}
