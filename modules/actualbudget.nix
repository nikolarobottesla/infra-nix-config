# requires arion pkg
{
  arion,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.actualbudget;
in {
  options.my.actualbudget = {
    enable = mkEnableOption "actualbudget server";

    dataDir = mkOption {
      type = types.str;
      description = "Defaults to...";
      default = null;
    };

    sslCertificate = mkOption {
      type = types.str;
      description = "Where to find ssl certificate";
      default = "/var/lib/tailscale-tls/cert.crt";
    };

    sslCertificateKey = mkOption {
      type = types.str;
      description = "Where to find ssl key";
      default = "/var/lib/tailscale-tls/key.key";
    };

  };

  config = mkIf cfg.enable {

    users.users.actualbudget = {
      group = "actualbudget";
      # home = "/var/lib/actualbudget";
      isSystemUser = true;
    };
    users.groups.actualbudget = {};

    systemd.tmpfiles.rules = [
      # "d /directory/to/create mode user group"
      "d ${cfg.dataDir} 0755 actualbudget actualbudget"
      #symlink SSL
      "C+ ${cfg.dataDir}/cert.crt - - - - ${cfg.sslCertificate}"
      "C+ ${cfg.dataDir}/key.key - - - - ${cfg.sslCertificateKey}"
    ];

    virtualisation.oci-containers.containers.actualbudget = {
      autoStart = true;
      environment = {
        # See all options and more details at
        # https://actualbudget.github.io/docs/Installing/Configuration
        ACTUAL_HTTPS_CERT = "/data/cert.crt";
        ACTUAL_HTTPS_KEY = "/data/key.key";
        # ACTUAL_UPLOAD_FILE_SYNC_SIZE_LIMIT_MB = 20;
        # ACTUAL_UPLOAD_SYNC_ENCRYPTED_FILE_SYNC_SIZE_LIMIT_MB = 50;
        # ACTUAL_UPLOAD_FILE_SIZE_LIMIT_MB = 20;
      };
      image = "ghcr.io/actualbudget/actual-server:latest";
      ports = ["5006:5006"];
      volumes = ["${cfg.dataDir}/:/data"];
    };
  };
}