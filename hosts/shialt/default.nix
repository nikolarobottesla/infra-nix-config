{
  config,
  inputs,
  lib,
  pkgs,
  options,
  ...
}: let
  device-name = "shialt";
  userName = "igor";
in {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.lanzaboote.nixosModules.lanzaboote
#     inputs.nixos-hardware.nixosModules.hp-elitebook-830g6
    inputs.nix-flatpak.nixosModules.nix-flatpak
    ./disko-config.nix
    ./hardware-configuration.nix
    # comment in after rclone config
    # (import ../../modules/rclone {
    #   userName = userName;
    #   remote-name = "pcloud";
    # })
    # (import ../../modules/rclone {
    #   userName = userName;
    #   remote-name = "onedrive";
    # })
  ];

  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;  # using lanzaboote

  networking.hostName = device-name; # Define your hostname
  
  my.desktop.userName = userName;
  my.desktop.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
