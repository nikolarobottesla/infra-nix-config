{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.cockpit;
in {
  options.my.cockpit = {
    enable = mkEnableOption "cockpit";

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

    # Cockpit will load a certificate from the /etc/cockpit/ws-certs.d
    systemd.tmpfiles.rules = [
      #symlink SSL
      # "L+ /etc/cockpit/ws-certs.d - - - - /var/lib/tailscale-tls"
      "L+ /etc/cockpit/ws-certs.d/cert.cert - - - - ${cfg.sslCertificate}"
      "L+ /etc/cockpit/ws-certs.d/cert.key - - - - ${cfg.sslCertificateKey}"
    ];

    services.cockpit = {
      enable = true;
      port = 9090;
      allowed-origins = [
        "https://oak-1.stork-galaxy.ts.net:9090"  # The public-facing URL clients will connect from in the browser
      ];
      # openFirewall = true; # Not needed for tailscale
      settings = {
        WebService = {
          AllowUnencrypted = false;
          # ProtocolHeader = "X-Forwarded-Proto";  # Specifies the request goes through a reverse proxy
        };
      };
    };
    
  };
}
