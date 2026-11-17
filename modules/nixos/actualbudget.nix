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
      description = "Defaults to null";
      default = null;
    };

    domain = mkOption {
      type = types.str;
      description = "Defaults to null";
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
      # Loopback only. The tailnet-facing listener is the `actual-tailnet`
      # nginx vhost below; nothing binds 0.0.0.0, so the app is unreachable
      # except through that vhost.
      ports = ["127.0.0.1:5006:5006"];
      user = "992:989";
      volumes = ["${cfg.dataDir}/:/data"];
    };

    # Actual Budget is loopback-only; nginx terminates the Tailscale cert on
    # the tailnet IP (cfg.domain, set per host) and proxies into it, so the app
    # is reachable only over the tailnet (never on 0.0.0.0). Mirrors the
    # `lldap-tailnet` vhost in hosts/oak-1/default.nix.
    services.nginx.virtualHosts."actual-tailnet" = {
      serverName = cfg.domain;
      addSSL = true;
      listen = [
        {
          addr = "100.92.38.20";
          port = 5006;
          ssl = true;
        }
      ];
      sslCertificate = "${config.my.tailscale-tls.certDir}/cert.crt";
      sslCertificateKey = "${config.my.tailscale-tls.certDir}/key.key";
      locations."/" = {
        proxyPass = "https://127.0.0.1:5006";
        extraConfig = ''
          proxy_ssl_verify off;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
        '';
      };
    };

    systemd.services.actual-tls = {
      description = "Copy Tailsscale tls into Actual Budget volume folder";
      #copy cert, symlinks are a challenge in mounted host directories5006
      # https://stackoverflow.com/questions/38485607/mount-host-directory-with-a-symbolic-link-inside-in-docker-container#40322275

      # not sure if it starts after or during
      after = ["tailscale-tls.service"];
      wantedBy = ["tailscale-tls.service"];

      serviceConfig.Type = "oneshot";
      script = ''
        DIRECTORY="${cfg.dataDir}"
        if [ ! -d "$DIRECTORY" ]; then
          echo "$DIRECTORY does not exist."
          mkdir "$DIRECTORY"
          chmod 0755 "$DIRECTORY"
          echo "$DIRECTORY created"
        fi

        CERT_FILE="$DIRECTORY/cert.crt"
        KEY_FILE="$DIRECTORY/key.key"

        rm -f "$CERT_FILE"
        rm -f "$KEY_FILE"

        cp "${cfg.sslCertificate}" "$CERT_FILE"
        cp "${cfg.sslCertificateKey}" "$KEY_FILE"

        chown actualbudget:actualbudget "$CERT_FILE" "$KEY_FILE"
        chmod 0640 "$CERT_FILE" "$KEY_FILE"
      '';
    };
  };
}