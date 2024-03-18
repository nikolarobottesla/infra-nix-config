# https://github.com/EricTheMagician/infrastructure/blob/main/modules/nextcloud.nix
{
  pkgs,
  lib,
  config,
  ...
}: let
  nextcloud_package = pkgs.nextcloud28;
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
        defaultPhoneRegion = "US";
        # extraTrustedDomains = [
        #   "oak-1"
        #   "100.92.38.20"
        # ];
        overwriteProtocol = "https";
      };
      # Let NixOS install and configure the database automatically.
      database.createLocally = true;

      package = nextcloud_package;
    };

    my.tailscale-tls.enable = true;

    services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
      forceSSL = true;
      sslCertificate = "${config.my.tailscale-tls.certDir}/cert.crt";
      sslCertificateKey = "${config.my.tailscale-tls.certDir}/key.key";
    };
    # allow nginx to read tailscale TLS
    users.users.nginx.extraGroups = [config.users.users.tailscale-tls.group];

  };
}