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

    sslCertificate = mkOption {
      type = types.str;
      description = "Where to find ssl certificate";
      default = "/var/lib/tailscale-tls/cert.crt";
    };

    sslCertificateKey = mkOption {
      type = types.str;
      description = "Where to find ssl key";
      default = "/var/lib/tailscale-tls/key.key";
    };

  };

  config = mkIf cfg.enable {

    users.users.syncthing = {
      # allow syncthing to read tailscale TLS  
      extraGroups = [config.users.users.tailscale-tls.group];
    };

    systemd.tmpfiles.rules = [
      # "z /directory/to/change/permissions mode user group"
      "Z /srv/array0/private/sync 0750 syncthing syncthing"
      "Z /srv/array0/private/c-save 0750 syncthing syncthing"
      "Z /srv/array0/private/k-cam-p6a 0750 syncthing syncthing"
      "Z /srv/array0/private/k-laptop 0750 syncthing syncthing"
      "Z /srv/array0/private/y-l 0750 syncthing syncthing"
      "Z /srv/array0/private/y-n---uid 0750 syncthing syncthing"
      "Z /srv/array0/media/music 0755 syncthing syncthing"
      #symlink SSL
      "C+ ${config.services.syncthing.configDir}/https-cert.pem - - - - ${cfg.sslCertificate}"
      "C+ ${config.services.syncthing.configDir}/https-key.pem - - - - ${cfg.sslCertificateKey}"
    ];

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
      "d-desk" = { id = "PJLY4GA-KIOBTGV-WDYMTJV-UJKE6NG-CP5DWMI-R3XTDRQ-LEBHRY6-7ICXLAG"; };
      "d-shi" = { id = "PAKP3VS-KF7CEEL-GR44ZIO-IH7TXRC-BUKEXNY-RTBTEM4-NOFX5EF-TSVYOAB"; };
      "m-phone" = { id = "EN5PJ54-II3PR5J-4O3HFU5-XSTPOUN-4AISVTI-FBPRULF-S2NYIJL-KC23RAN"; };
      "k-phone" = { id = "XXCT5MM-HAPGZUX-KNOL4C4-2Q6IWUR-3R6STHN-IC5OL6C-AYZHM5Z-A23XBA6"; };
      "laptop840" = { id = "Q4MJJUY-A6ILQNI-GF2YZYA-ITQFNMM-EOW4QIZ-HGGG6MJ-E7CZH5G-LQ755AD"; };
      "12th-turtle" = { id = "65XCMJ3-72TNTUL-P66NMZP-DEOYSXU-IRXBLPC-OXUMWXF-REI2J56-DZHMIA7"; };
      "cinnamon-ice" = { id = "OAEXK4I-LXC3XUF-4Y57RI7-B3Q7BKO-RBVZWXQ-AGV5CD3-W5MVPXV-EY5Z6QE"; };
      # "device" = { id = "DEVICE-ID-GOES-HERE"; };
    };

    services.syncthing.settings.folders = {
      "default" = {  # Name of folder in Syncthing, also the default folder ID
        id = "default";  # needs to be the same for all devices
        path = "/srv/array0/private/sync";  # Which folder to add to Syncthing
        devices = [ "15th-turtle" "d-desk" "d-shi" "laptop840" "12th-turtle" ];  # Which devices to share the folder with
        type = "receiveonly";
      };
      "music" = {
        id = "zt4nl-ymozz";
        path = "/srv/array0/media/music";
        devices = [ "15th-turtle" "d-desk" "d-shi" "m-phone"];
        type = "receiveonly";
      };
      "k-cam-p6a" = {
        id = "pixel_6a_3y3s-photos";
        path = "/srv/array0/private/k-cam-p6a";
        devices = [ "k-phone" ];
        type = "receiveonly";
      };
      "k-laptop-desktop" = { 
        id = "rehhq-athup";
        path = "/srv/array0/private/k-laptop/desktop";
        devices = [ "laptop840" "12th-turtle" "cinnamon-ice"] ;
        type = "receiveonly";
      };
      "k-laptop-music" = { 
        id = "qrysd-avxft";
        path = "/srv/array0/private/k-laptop/music";
        devices = [ "laptop840" "12th-turtle" "k-phone" ];
        type = "receiveonly";
      };
      "k-laptop-pictures" = { 
        id = "rrmn9-ybzyr";
        path = "/srv/array0/private/k-laptop/pictures";
        devices = [ "laptop840" "12th-turtle" ];
        type = "receiveonly";
      };
      "k-laptop-videos" = { 
        id = "4tkum-u9ttx";
        path = "/srv/array0/private/k-laptop/videos";
        devices = [ "laptop840" "12th-turtle" ];
        type = "receiveonly";
      };
      "c-save" = {
        id = "gdd7v-qhybv";
        path = "/srv/array0/private/c-save";
        devices = [ "d-desk" ];
        type = "receiveonly";
      };
      "y-n---uid" = {
        id = "mxrph-92u7u";
        path = "/srv/array0/private/y-n---uid";
        devices = [ "d-desk" ];
        type = "receiveonly";
      };
      "y-l" = {
        id = "pvndr-ukxex";
        path = "/srv/array0/private/y-l";
        devices = [ "d-desk" ];
        type = "receiveonly";
      };
    };
  };

}
