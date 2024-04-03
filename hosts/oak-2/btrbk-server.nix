{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.btrbk-server;
in {
  options.my.btrbk-server = {
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
      # createHome = true;
      # extraGroups = [];
      group = "btrbk";
      # home = "/var/lib/btrbk";
      isSystemUser = true;
      # openssh.authorizedKeys.keys = [
      #   ""
      # ];
    };

    security.sudo = {
      enable = true;
      extraRules = [{
        commands = [
          {
            command = "${pkgs.coreutils-full}/bin/test";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.coreutils-full}/bin/readlink";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.btrfs-progs}/bin/btrfs";
            options = [ "NOPASSWD" ];
          }
        ];
        users = [ "btrbk" ];
      }];
    };

  };
}