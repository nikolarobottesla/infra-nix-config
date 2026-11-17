# https://github.com/EricTheMagician/infrastructure/blob/main/modules/nextcloud.nix
{
  pkgs,
  lib,
  config,
  ...
}: let
  nextcloud_package = pkgs.nextcloud35;
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
    publicDomain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Optional public FQDN (e.g. via Traefik/Cloudflare) in addition to the tailnet domain.";
    };
    trustedProxies = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Proxy addresses trusted for X-Forwarded-* headers.";
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
        overwriteprotocol = "https";
        trusted_domains = lib.optional (cfg.publicDomain != null) cfg.publicDomain;
        trusted_proxies = cfg.trustedProxies;
      };
      # Let NixOS install and configure the database automatically.
      database.createLocally = true;

      package = nextcloud_package;
    };

    # Answer for the public hostname on the same vhost as the tailnet domain.
    # Repeat the nginx module's default loopback aliases because any explicit
    # serverAliases definition overrides that mkDefault list.
    services.nginx.virtualHosts.${cfg.domain}.serverAliases =
      ["127.0.0.1"]
      ++ lib.optional config.networking.enableIPv6 "[::1]"
      ++ lib.optional (cfg.publicDomain != null) cfg.publicDomain;

  };
}