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

    hashedPasswordFile = mkOption {
      type = types.path;
      example = literalExpression ''
        config.sops.secrets."code-server-hashed-pass".path
      '';
      description = ''
        Path to a systemd {manpage}`systemd.exec(5)` `EnvironmentFile` holding
        the password hash on a single line:

        ```
        HASHED_PASSWORD=$argon2i$v=19$m=65536,t=3,p=1$...
        ```

        PID 1 reads this file when the unit starts, so a secret owned by
        sops-nix (by default `/run/secrets/...`) never enters the Nix store or
        the unit file. The hash is a reusable credential, so keeping it out of
        the store also keeps it out of every system closure and out of reach of
        anyone who can read the store or the repository history.

        This is the only way to set the password: the upstream
        {option}`services.code-server.hashedPassword` option is deliberately
        not exposed, and its `Environment=HASHED_PASSWORD=` assignment is
        removed from the generated unit, leaving this file as the sole source of
        the hash.

        A missing or unreadable file makes the unit fail to start, so a wrong
        path fails closed instead of silently falling back to an empty
        password.

        Generate a hash with (this build of {command}`libargon2` spells the
        memory cost `-k`, in KiB):

        {command}`printf %s 'mypassword' | nix run nixpkgs#libargon2 -- "$(head -c 20 /dev/urandom | base64)" -e -k 65536 -t 3 -p 1`
      '';
    };
  };

  config = mkIf cfg.enable {

    services.code-server = {
      auth = "password";
      disableTelemetry = true;
      disableUpdateCheck = true;
      enable = true;
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

    # NixOS omits null environment values, so this drops the upstream
    # `Environment=HASHED_PASSWORD=` assignment that `hashedPassword` (empty by
    # default) would otherwise produce, leaving `hashedPasswordFile` as the
    # only source of the hash.
    systemd.services.code-server = {
      environment.HASHED_PASSWORD = mkForce null;
      serviceConfig.EnvironmentFile = [ cfg.hashedPasswordFile ];
    };

    # allow code-server user to read tailscale TLS
    users.users.${cfg.userName}.extraGroups = [config.users.users.tailscale-tls.group];

  };
}
