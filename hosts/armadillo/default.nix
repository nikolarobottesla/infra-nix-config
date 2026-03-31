{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  hostName = "armadillo";
  userName = "igor";
in {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = hostName;

  hardware.asahi = {
    enable = true;
    # manually copy firmware during install, see nixos-apple-silicon guide
    # peripheralFirmwareDirectory = /etc/nixos/firmware; # post install path
    peripheralFirmwareDirectory = /mnt/etc/nixos/firmware; # /mnt... pre instsall, updated post install
    #extractPeripheralFirmware = false;
    setupAsahiSound = true;
  };

  networking.networkmanager.enable = false; # need to disable for iwd?
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  my.laptop.enable = true;
  my.desktop-base.userName = userName;
  # my.desktop-dev.userName = userName;
  # my.desktop-dev.homeStateVersion = "25.11";
  my.desktop-base.enable = true;
  # my.desktop-dev.enable = true;

  nix.settings = {
    extra-substituters = [
      "https://nixos-apple-silicon.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
  };

  services.tailscale.useRoutingFeatures = "client";

  system.stateVersion = "25.11";
}
