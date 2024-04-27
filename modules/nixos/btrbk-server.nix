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
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAYLoGANzPOjl7K9KF6Ie43GfLArkSfUoS0eBCuoWl90 btrbk";
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