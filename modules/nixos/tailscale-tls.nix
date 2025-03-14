# from https://github.com/dr460nf1r3/dr460nixed/blob/main/nixos/modules/tailscale-tls.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.tailscale-tls;
  domainExpression =
    if cfg.domain-override != null
    then cfg.domain-override
    else "$(${pkgs.tailscale}/bin/tailscale cert 2>&1 | grep use | cut -d '\"' -f2)";
in {
  options.my.tailscale-tls = {
    enable = mkEnableOption "Automatic Tailscale certificates renewal";

    certDir = mkOption {
      type = types.str;
      description = "Where to put certificates";
      default = "/var/lib/tailscale-tls";
    };

    mode = mkOption {
      type = types.str;
      description = "File mode for certificates";
      default = "0640";
    };

    domain-override = mkOption {
      type = types.nullOr types.str;
      description = "Override domain. Defaults to suggested one by tailscale";
      default = null;
    };
  };

  config = mkIf cfg.enable {
    users.users.tailscale-tls = {
      group = "tailscale-tls";
      home = "/var/lib/tailscale-tls";
      isSystemUser = true;
    };

    users.groups.tailscale-tls = {};

    systemd.services.tailscale-tls = {
      description = "Automatic Tailscale certificates";

      after = ["network-pre.target" "tailscale.service"];
      wants = ["network-pre.target" "tailscale.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig.Type = "oneshot";
      script = ''
        status="Starting"

        until [ $status = "Running" ]; do
          sleep 2
          status=$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)
        done

        mkdir -p "${cfg.certDir}"

        DOMAIN=${domainExpression}
        CERT_FILE="${cfg.certDir}/cert.crt"
        KEY_FILE="${cfg.certDir}/key.key"

        # saved cert and key files don't seem to get updated when expired so removing the files
        rm -f "$CERT_FILE"
        rm -f "$KEY_FILE"

        ${pkgs.tailscale}/bin/tailscale cert \
          --cert-file "$CERT_FILE" \
          --key-file "$KEY_FILE" \
          "$DOMAIN"

        chown -R tailscale-tls:tailscale-tls "${cfg.certDir}"

        chmod ${cfg.mode} "${cfg.certDir}/cert.crt" "${cfg.certDir}/key.key"
      '';
    };

    systemd.timers.tailscale-tls = {
      description = "Automatic Tailscale certificates renewal";

      after = ["network-pre.target" "tailscale.service"];
      wants = ["network-pre.target" "tailscale.service"];
      wantedBy = ["multi-user.target"];

      timerConfig = {
        OnCalendar = "weekly";
        Persistent = "true";
        Unit = "tailscale-tls.service";
      };
    };
  };
}
