{ config, inputs, lib, options, pkgs, ... }:
with lib; let
  cfg = config.my.pi4;
in 
{
  options.my.pi4 = {
    enable = mkEnableOption "pi4 hardware";
  };
  
  config =  mkIf cfg.enable {
    # imports = [
    #     inputs.nixos-hardware.nixosModules.raspberry-pi-4
    # ];

    # Free up to 2GiB whenever there is less than 500MiB left.
    nix.extraOptions = ''
        min-free = ${toString (500 * 1024 * 1024)}
        max-free = ${toString (2048 * 1024 * 1024)}
    '';

    hardware = {
        raspberry-pi."4".apply-overlays-dtmerge.enable = true;
        deviceTree = {
        enable = true;
        filter = "*rpi-4-*.dtb";
        };
    };

    environment.systemPackages = with pkgs; [
        libraspberrypi
        raspberrypi-eeprom
    ];
  };
}