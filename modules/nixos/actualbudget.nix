{
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
      # extraGroups = [config.users.users.tailscale-tls.group];
      group = "actualbudget";
      # home = "/var/lib/actualbudget";
      isSystemUser = true;
      uid = 992;
    };
    users.groups.actualbudget = {
      gid = 989;
    };

    systemd.tmpfiles.rules = [
      # "d /directory/to/create mode user group"
      "d ${cfg.dataDir} 0755 actualbudget actualbudget"
      #copy cert, symlinks are a challenge in mounted host directories
      # https://stackoverflow.com/questions/38485607/mount-host-directory-with-a-symbolic-link-inside-in-docker-container#40322275
      "C+ ${cfg.dataDir}/cert.crt 0640 actualbudget actualbudget - ${cfg.sslCertificate}"
      "C+ ${cfg.dataDir}/key.key 0640 actualbudget actualbudget - ${cfg.sslCertificateKey}"
    ];

    virtualisation.oci-containers.containers.actualbudget = {
      autoStart = true;
      environment = {
        # See all options and more details at
        # https://actualbudget.github.io/docs/Installing/Configuration
        ACTUAL_HTTPS_CERT = "/data/cert.crt";
        ACTUAL_HTTPS_KEY = "/data/key.key";
        # ACTUAL_HOSTNAME = "<ts domain>";
        # ACTUAL_UPLOAD_FILE_SYNC_SIZE_LIMIT_MB = 20;
        # ACTUAL_UPLOAD_SYNC_ENCRYPTED_FILE_SYNC_SIZE_LIMIT_MB = 50;
        # ACTUAL_UPLOAD_FILE_SIZE_LIMIT_MB = 20;
      };
      # hostname = "<ts domain>";
      image = "ghcr.io/actualbudget/actual-server:latest";
      ports = ["5006:5006"];
      user = "992:989";
      volumes = ["${cfg.dataDir}/:/data"];
    };

    # services.nginx.virtualHosts."oak-1.budget.stork-galaxy.ts.net" = {
    #   locations."/".proxyPass = "https://localhost:5006";
    #   # forceSSL = true;
    #   # useACMEHost = "stork-galaxy.ts.net";
    # };
  };
}