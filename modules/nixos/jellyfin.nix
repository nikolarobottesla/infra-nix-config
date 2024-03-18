{ lib, config, pkgs, ... }:

with lib; let
  cfg = config.my.jellyfin;
in {
  options.my.jellyfin = {
    enable = mkEnableOption "actualbudget server";
  };

  config = mkIf cfg.enable {

    boot.kernelParams = [
      "i915.enable_guc=2"
    ];

    hardware.opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-compute-runtime
      ];
    };

    users.users.jellyfin = {
      packages = with pkgs; [
        jellyfin
        jellyfin-web
        jellyfin-ffmpeg
      ];
    };

    services.jellyfin = {
      enable = true;
      openFirewall = true;
      user = "jellyfin"; # default
      group = "jellyfin"; # default
    };
  };

}
