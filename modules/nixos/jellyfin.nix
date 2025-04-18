{ lib, config, pkgs, ... }:

with lib; let
  cfg = config.my.jellyfin;
in {
  options.my.jellyfin = {
    enable = mkEnableOption "jellyfin server";
  };

  config = mkIf cfg.enable {
    
    # should use quicksync for transcoding 
    # https://discourse.nixos.org/t/jellyfin-qsv-config/37717
    
    boot.kernelParams = [
      "i915.enable_guc=2"
    ];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-compute-runtime
      ];
    };

    users.users.jellyfin = {
      # isSystemUser = true;
      extraGroups = [ "samba-users" ];  # read/write access to media
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
