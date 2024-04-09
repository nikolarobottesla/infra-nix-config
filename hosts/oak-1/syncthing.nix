{ lib, config, pkgs, ... }:

with lib; let
  cfg = config.my.syncthing;
in {
  options.my.syncthing = {
    enable = mkEnableOption "syncthing";

    key = mkOption {
      type = types.null or types.str;
      description = "key.pem";
      default = null;
    };

    cert = mkOption {
      type = types.null or types.str;
      description = "cert.pem file";
      default = null;
    };

  };

  config = mkIf cfg.enable {

    services.syncthing = {
      enable = true;
      cert = cfg.cert;
      key = cfg.key;
      relay = {
        enable = true;
      };
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

    };
  };

}
