# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ hostName, ... }: { config, home-manager, inputs, lib, options, pkgs, ... }:
let
  userName = "nixos";
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ../../modules/nixos/pi4.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "${hostName}"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  my.pi4.enable = true;

  console.enable = false;

  sops.secrets = {
    hashedPassFile = {
      sopsFile = ./secrets-${hostName}.yaml;
      neededForUsers = true;
    };
    create_ap_conf = {
      sopsFile = ./secrets-${hostName}.yaml;
    };
  };

  my.user.userName = userName;
  my.user.hashedPassFile = config.sops.secrets.hashedPassFile.path;

  home-manager.users."${userName}" = import ../../home-manager/home.nix;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    linux-wifi-hotspot
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    # leaving pinentryFlavor default was causing mismatch dependency error
    # "curses, tty also caused the same error
    pinentryFlavor = null;
  };

  my.create_ap = {
    enable = true;
    configPath = config.sops.secrets.create_ap_conf.path;
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
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