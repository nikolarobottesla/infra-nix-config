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
  };

  config = mkIf cfg.enable {

    services.btrbk = {
      sshAccess = [{
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6cFQNIsuvhieF64I3ZHKAN6DcH4sBLJJX4d3NxMI6h btrbk";
        roles = [
          "send"
          "source"
          "info"
        ];
      }];
 
      extraPackages = [pkgs.lz4];
    }
    
    # for transport stream encryption
    # environment.systemPackages = [ pkgs.lz4 ];

    # users.users.btrbk = {
    #   # createHome = true;
    #   # extraGroups = [];
    #   group = "btrbk";
    #   # home = "/var/lib/btrbk";
    #   isSystemUser = true;
    #   openssh.authorizedKeys.keys = [
    #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6cFQNIsuvhieF64I3ZHKAN6DcH4sBLJJX4d3NxMI6h btrbk"
    #   ];
    # };

    # security.sudo = {
    #   enable = true;
    #   extraRules = [{
    #     commands = [
    #       {
    #         command = "${pkgs.coreutils-full}/bin/test";
    #         options = [ "NOPASSWD" ];
    #       }
    #       {
    #         command = "${pkgs.coreutils-full}/bin/readlink";
    #         options = [ "NOPASSWD" ];
    #       }
    #       {
    #         command = "${pkgs.btrfs-progs}/bin/btrfs";
    #         options = [ "NOPASSWD" ];
    #       }
    #     ];
    #     users = [ "btrbk" ];
    #   }];
    # };

  };
}