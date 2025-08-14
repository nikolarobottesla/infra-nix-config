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

    host = mkOption {
      type = types.str;
      description = "defaults to 0.0.0.0";
      default = "0.0.0.0";
    };

    hostName = mkOption {
      type = types.str;
      description = "host name";
      default = "";
    };
  };

  config = mkIf cfg.enable {

    sops.secrets = {
      code-server-hashed-pass = {
        sopsFile = ".../${hostName}/secrets.yaml";
      };
    };

    services.code-server = {
      auth = "password";
      disableTelemetry = true;
      disableUpdateCheck = true;
      enable = true;
      hashedPassword = builtins.readFile config.sops.secrets.code-server-hashed-pass.path;
      user = cfg.userName;
      userDataDir = "/home/${cfg.userName}/.code_server_data";
      host = cfg.host;
      port = 3000;
      # extraPackages = [ pkgs.sqlite pkgs.nodejs pkgs.nixpkgs-fmt pkgs.nixd pkgs.git ];

      # extraEnvironment = {
      
      # };
      extraArguments = [
        "--cert=${config.my.tailscale-tls.certDir}/cert.crt"
        "--cert-key=${config.my.tailscale-tls.certDir}/key.key"
        # "--log=info"
      ];
    };

    # allow code-server user to read tailscale TLS
    users.users.${cfg.userName}.extraGroups = [config.users.users.tailscale-tls.group];

  };
}
