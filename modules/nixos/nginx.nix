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

      # nginx binds the tailnet IP for the `lldap-tailnet` / `actual-tailnet`
      # vhosts. During a switch that restarts tailscaled the address is briefly
      # gone, and nginx's config test then fails with "Cannot assign requested
      # address" (making switch-to-configuration exit 4). Wait for tailscale0 to
      # have its address before the config test runs.
      services.nginx.preStart = ''
        n=0
        while [ "$n" -lt 60 ]; do
          if ${pkgs.iproute2}/bin/ip -4 addr show dev tailscale0 2>/dev/null | ${pkgs.gnugrep}/bin/grep -q 'inet '; then
            break
          fi
          n=$((n + 1))
          ${pkgs.coreutils}/bin/sleep 1
        done
      '';

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