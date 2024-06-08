# https://github.com/EricTheMagician/infrastructure/blob/main/modules/nextcloud.nix
{
  pkgs,
  lib,
  config,
  ...
}: let
  nextcloud_package = pkgs.nextcloud29;
  cfg = config.my.nextcloud;
  inherit (lib) mkOption mkEnableOption types mkIf;
in {
  imports = [ ./tailscale-tls.nix ];
  
  options.my.nextcloud = {
    enable = mkEnableOption "Enable Nextcloud";
    domain = mkOption {
      type = types.str;
      default = "oak-1.stork-galaxy.ts.net";
    };
    homeDir = mkOption {
      type = types.str;
      default = "/srv/array0/services/nextcloud";
    };
    adminpassFile = mkOption {
      type = types.str;
      default = null;
      description = "Required, no default";
    };
  };
  config = mkIf cfg.enable {

    # make sure an nginx Vhost is configured for the domain

    services.nextcloud = {
      enable = true;
      appstoreEnable = true;
      autoUpdateApps.enable = true;
      home = cfg.homeDir;
      hostName = cfg.domain;
      https = true;
      maxUploadSize = "32G";
      # Let NixOS install and configure Redis caching automatically.
      configureRedis = true;
      config = {
        adminuser = "admin";
        adminpassFile = cfg.adminpassFile;
        dbtype = "pgsql";
      };
      settings = {
        defaultPhoneRegion = "US";
        overwriteProtocol = "https";
      };
      # Let NixOS install and configure the database automatically.
      database.createLocally = true;

      package = nextcloud_package;
    };

  };
}