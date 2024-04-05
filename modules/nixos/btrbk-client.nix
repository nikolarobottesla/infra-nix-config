{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.btrbk-client;
  ssh_identity = "btrbk_key";
  key_path = "/var/lib/btrbk/${ssh_identity}";
in {
  options.my.btrbk-client = {
    enable = mkEnableOption "enable btrkbk server";

    remoteHost = mkOption {
      type = types.str;
      description = "remote host network name";
      default = "oak-2";
    };

  };

  config = mkIf cfg.enable {

    system.activationScripts.btrbkUserSetup.text = ''
      if [ ! -f "${key_path}" ]; then
        echo "${ssh_identity} file not found, generating SSH key"
        ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -N "" -C "btrbk" -f "${key_path}"
      fi
    '';

    services.btrbk = {
      # manual dry run
      # btrbk -c /etc/btrbk/send_remote.conf --dry-run --progress --verbose run
      instances."send_remote" = {
        onCalendar = "weekly";
        settings = {
          ssh_identity = "${key_path}"; # NOTE: must be readable by user/group btrbk
          ssh_user = "btrbk";
          stream_compress = "lz4";
          volume."/srv/array0" = {
            snapshot_create = "onchange";
            snapshot_preserve = "1d 1w 1m 1y";
            snapshot_preserve_min = "latest";
            target = "ssh://${cfg.remoteHost}/srv/array0";
            target_preserve = "1d 1w 1m 1y";
            target_preserve_min = "latest";
            subvolume = "*";
          };
        };
      };
 
      extraPackages = [pkgs.lz4];
    };

  };
}