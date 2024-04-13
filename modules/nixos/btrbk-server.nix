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
          "delete"
          "info"
          "target"
        ];
      }];
 
      extraPackages = [pkgs.lz4];
    }; 

  };
}