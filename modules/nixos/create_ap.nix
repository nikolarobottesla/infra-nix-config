{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my.create_ap;
  configFile = cfg.configPath;
in {
  options = {
    my.create_ap = {
      enable = mkEnableOption (lib.mdDoc "setting up wifi hotspots using create_ap");
      settings = mkOption {
        type = with types; attrsOf (oneOf [ int bool str ]);
        default = {};
        description = lib.mdDoc ''
          Configuration for `create_ap`.
          See [upstream example configuration](https://raw.githubusercontent.com/lakinduakash/linux-wifi-hotspot/master/src/scripts/create_ap.conf)
          for supported values.
        '';
        example = {
          INTERNET_IFACE = "eth0";
          WIFI_IFACE = "wlan0";
          SSID = "My Wifi Hotspot";
          PASSPHRASE = "12345678";
        };
      };
      configPath = mkOption {
        type = types.str;
        default = pkgs.writeText "create_ap.conf" (generators.toKeyValue { } cfg.settings);
        description = lib.mdDoc ''
          Configuration file path for `create_ap`, overrides settings.
          See [upstream example configuration](https://raw.githubusercontent.com/lakinduakash/linux-wifi-hotspot/master/src/scripts/create_ap.conf)
          for supported values.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    systemd = {
      services.create_ap = {
        wantedBy = [ "multi-user.target" ];
        description = "Create AP Service";
        after = [ "network.target" ];
        restartTriggers = [ configFile ];
        serviceConfig = {
          ExecStart = "${pkgs.linux-wifi-hotspot}/bin/create_ap --config ${configFile}";
          KillSignal = "SIGINT";
          Restart = "on-failure";
        };
      };
    };

  };

}
