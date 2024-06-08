{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.code-server;
in {
  options.my.code-server = {
    enable = mkEnableOption "code-server";

    userName = mkOption {
      type = types.str;
      description = "defaults to code-server";
      default = "code-server";
    };
  };

  config = mkIf cfg.enable {

    services.code-server = {
      auth = "none";
      disableTelemetry = true;
      disableUpdateCheck = true;
      enable = true;
      user = cfg.userName;
      userDataDir = "/home/${cfg.userName}/.code_server_data";
      host = "0.0.0.0";
      # host = "oak-1.stork-galaxy.ts.net";
      port = 3000;
      # extraPackages = [ pkgs.sqlite pkgs.nodejs pkgs.nixpkgs-fmt pkgs.nixd pkgs.git ];

      # extraEnvironment = {
      
      # };
      # extraArguments = [
      #   "--log=info"
      # ];
    };

    # get SSL_ERROR_RX_RECORD_TOO_LONG
    # my.nginx.enable = true;
    # services.nginx.virtualHosts.${config.services.openvscode-server.host} = {
    #   forceSSL = true;
    #   sslCertificate = "${config.my.tailscale-tls.certDir}/cert.crt";
    #   sslCertificateKey = "${config.my.tailscale-tls.certDir}/key.key";
    # };

  };
}
