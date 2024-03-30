{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  userName = config.users.users.main.name;
  cfg = config.my.openvscode-server;
in {
  options.my.openvscode-server = {
    enable = mkEnableOption "openvscode-server";
  };

  config = mkIf cfg.enable {

    services.openvscode-server = {
        enable = true;
        user = "${userName}";
        userDataDir = "/home/${userName}/.vscode_server";
        host = "0.0.0.0";
        # host = "oak-1.stork-galaxy.ts.net";
        port = 3000;
        # extraPackages = [ pkgs.sqlite pkgs.nodejs pkgs.nixpkgs-fmt pkgs.nixd pkgs.git ];
        withoutConnectionToken = true;
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