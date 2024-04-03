{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.btrbk-client;
in {
  options.my.btrbk-client = {
    enable = mkEnableOption "enable btrkbk server";

    # flake = mkOption {
    #   type = types.str;
    #   description = "flake link";
    #   default = "github:nikolarobottesla/infra-nix-config";
    # };

  };

  config = mkIf cfg.enable {
    
    # for transport stream encryption
    environment.systemPackages = [ pkgs.lz4 ];

    users.users.btrbk = {
      createHome = true;
      # extraGroups = [];
      group = "btrbk";
      home = "/var/lib/btrbk";
      isSystemUser = true;
    };

    services.btrbk = {
    instances."send_remote" = {
        onCalendar = "weekly";
        settings = {
          ssh_identity = "/var/lib/btrbk/btrbk_key"; # NOTE: must be readable by user/group btrbk
          ssh_user = "btrbk";
          stream_compress = "lz4";
          volume."/srv/" = {
              target = "ssh://myhost/mnt/mybackups";
              subvolume = "nixos";
          };
        };
    };
    };

  };
}