{
  lib,
  config,
  pkgs,
  ... }:

with lib; let
  cfg = config.my.dns;
in {
  options.my.dns = {
    enable = mkEnableOption "use my dns settings";
  };

  config = mkIf cfg.enable {
    # DNS config
    networking.nameservers = [ 
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
        ];
    services.resolved = {
        enable = true;
        dnssec = "false";
        # domains = [ "~." ];
        fallbackDns = null;  # when null a default list is used
        dnsovertls = "opportunistic";
    };
  };
}
