{
  pkgs,
  lib,
  config,
  ...
}: let
  # nginx_package = ;
  cfg = config.my.nginx;
  inherit (lib) mkOption mkEnableOption types mkIf;
in {
  imports = [ ./tailscale-tls.nix ];
  
  options.my.nginx = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    domain = mkOption {
      type = types.str;
      default = "$(${pkgs.tailscale}/bin/tailscale cert 2>&1 | grep use | cut -d '\"' -f2)";
    };
  };
  config =
    mkIf config.my.nginx.enable {

      users.users.nginx = {
        # allow nginx to read tailscale TLS  
        extraGroups = [config.users.users.tailscale-tls.group];
        group = "nginx";
        home = "/var/lib/nginx";
        isSystemUser = true;
      };

      services.nginx = {
        enable = true;
        # package = nginx_package;
        # recommendedBrotliSettings = true;
        # recommendedGzipSettings = true;
        recommendedOptimisation = true;
        # recommendedProxySettings = true;
        # recommendedTlsSettings = true;
        # recommendedZstdSettings = true;
        # virtualHosts."localhost" = {
        #   rejectSSL = true;
        #   default = true;
        #   locations."/" = {
        #     return = "444";
        #   };
        # };
      };

      my.tailscale-tls.enable = true;

      # don't know how to use, need to find an example
      # services.nginx.tailscaleAuth = {
      #   enable = true;
      #   expectedTailnet = "stork-galaxy.ts.net";
      #   virtualHosts = [

      #   ];
      # };

      services.nginx.virtualHosts.${cfg.domain} = {
        forceSSL = true;
        sslCertificate = "${config.my.tailscale-tls.certDir}/cert.crt";
        sslCertificateKey = "${config.my.tailscale-tls.certDir}/key.key";
      };

      # tailscale only
      # networking.firewall = {
      #   # ports needed for dns
      #   allowedTCPPorts = [80 443];
      # };
  };
}