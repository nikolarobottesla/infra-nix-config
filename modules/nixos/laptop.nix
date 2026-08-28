{
  lib,
  config,
  pkgs,
  ... }:
with lib; let
  cfg = config.my.laptop;
in {
  options.my.laptop = {
    enable = mkEnableOption "laptop specific stuff";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
        acpi # check charge state
    ];
    
  };
}
