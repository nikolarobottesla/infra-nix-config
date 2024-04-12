{ lib, config, pkgs, ... }:

with lib; let
  cfg = config.my.syncthing;
in {
  options.my.syncthing = {
    enable = mkEnableOption "syncthing";

    key = mkOption {
      type = types.nullOr types.str;
      description = "key.pem";
      default = null;
    };

    cert = mkOption {
      type = types.nullOr types.str;
      description = "cert.pem file";
      default = null;
    };

  };

  config = mkIf cfg.enable {

    # TODO add tmpfs rules to modify the permissions of syncthing folders or change user/group?

    services.syncthing = {
      enable = true;
      guiAddress = "0.0.0.0:8384";
      cert = cfg.cert;
      key = cfg.key;
      relay = {
        enable = true;
      };
      openDefaultPorts = false;
      overrideDevices = true;
      overrideFolders = true;
    };
    
    services.syncthing.settings.devices = {
      "15th-turtle" = { id = "4ZHN65B-XEZS64F-GW4JTWO-GBDBZIC-SMNABCN-ASAPGRZ-5XUKLUO-ZMPFJQG"; };
      "d-desk" = { id = "UNU2HQD-UAA4JYP-PFJ52KC-PXNMKAE-B2CT4TO-6O2W6IV-56MQKLF-UQPAHQ7"; };
      "d-shi" = { id = "PAKP3VS-KF7CEEL-GR44ZIO-IH7TXRC-BUKEXNY-RTBTEM4-NOFX5EF-TSVYOAB"; };
      "k-phone" = { id = "XXCT5MM-HAPGZUX-KNOL4C4-2Q6IWUR-3R6STHN-IC5OL6C-AYZHM5Z-A23XBA6"; };
      "laptop840" = { id = "Q4MJJUY-A6ILQNI-GF2YZYA-ITQFNMM-EOW4QIZ-HGGG6MJ-E7CZH5G-LQ755AD"; };
      "12th-turtle" = { id = "EKFW33Y-WMNY6H5-CMKS4UU-F7NTXGT-RPN5YEO-JLBBDJM-QYB3UK7-6OEW5A4"; };
      # "device" = { id = "DEVICE-ID-GOES-HERE"; };
    };

    services.syncthing.settings.folders = {
      "default" = {  # Name of folder in Syncthing, also the default folder ID
        id = "default";  # needs to be the same for all devices
        path = "/srv/array0/private/sync";  # Which folder to add to Syncthing
        devices = [ "15th-turtle" "d-desk" "d-shi" "laptop840" "12th-turtle" ];  # Which devices to share the folder with
      };
      # "music" = {
      #   # TODO , receive only?
      #   id = "zt4nl-ymozz";
      #   path = "/srv/array0/media/music";
      #   devices = [ "15th-turtle" "d-desk" "d-shi" ];
      #   # type = "receiveonly";
      # };
      # "k-cam-p6a" = {
      #   id = "pixel_6a_3y3s-photos";
      #   path = "/srv/array0/private/k-cam-p6a";
      #   devices = [ "k-phone" ];
      # };
      # "k-laptop-desktop" = { 
      #   id = "rehhq-athup";
      #   path = "/srv/array0/private/k-laptop/desktop";
      #   devices = [ "laptop840" "12th-turtle" ];
      # };
      # "k-laptop-music" = { 
      #   id = "qrysd-avxft";
      #   path = "/srv/array0/private/k-laptop/music";
      #   devices = [ "laptop840" "12th-turtle" "k-phone" ];
      # };
      # "k-laptop-pictures" = { 
      #   id = "rrmn9-ybzyr";
      #   path = "/srv/array0/private/k-laptop/pictures";
      #   devices = [ "laptop840" "12th-turtle" ];
      # };
      # "k-laptop-videos" = { 
      #   id = "4tkum-u9ttx";
      #   path = "/srv/array0/private/k-laptop/videos";
      #   devices = [ "laptop840" "12th-turtle" ];
      # };
      # "c-save" = {
      #   id = "gdd7v-qhybv";
      #   path = "/srv/array0/private/c-save";
      #   devices = [ "d-desk" ];
      # };
      # "y-n---uid" = {
      #   id = "mxrph-92u7u";
      #   path = "/srv/array0/private/y-n---uid";
      #   devices = [ "d-desk" ];
      # };
      # "y-l" = {
      #   id = "pvndr-ukxex";
      #   path = "/srv/array0/private/y-l";
      #   devices = [ "d-desk" ];
      # };
    };
  };

}
