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
  };
  config =
    mkIf config.my.nginx.enable {

      my.tailscale-tls.enable = true;

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
        # recommendedOptimisation = true;
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

      # tailscale only
      # networking.firewall = {
      #   # ports needed for dns
      #   allowedTCPPorts = [80 443];
      # };
  }
}