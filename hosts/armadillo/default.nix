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

  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];  # run more flatpaks etc
  boot.kernelParams = [ "appledrm.show_notch=1" ];  # Macbook has a notch 
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = hostName;

  hardware.asahi = {
    enable = true;
    # manually copy firmware during install, see nixos-apple-silicon guide
    peripheralFirmwareDirectory = /etc/nixos/firmware; # post install path
    # peripheralFirmwareDirectory = /mnt/etc/nixos/firmware; # during install paths
    # extractPeripheralFirmware = false;
    setupAsahiSound = true;
  };

  # iwd recommended 
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };
  networking.networkmanager.wifi.backend = "iwd";

  my.laptop.enable = true;
  my.desktop-base.userName = userName;
  my.desktop-dev.userName = userName;
  my.desktop-dev.homeStateVersion = "25.11";
  my.desktop-base.enable = true;
  my.desktop-dev.enable = true;

  nix.settings = {
    extra-substituters = [
      "https://nixos-apple-silicon.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
  };

  # 20260406 USB power doesn't resume automaticallyy for attached devices
  # the 1st option here didn't work, there don't appear to be any xhci_hcd drivers to unbind/bind
  # powerManagement.resumeCommands = ''
  #   # Find USB controllers
  #   for controller in /sys/bus/pci/drivers/xhci_hcd/*:*; do
  #     if [ -d "$controller" ]; then
  #       echo "Resetting USB controller: $controller"
  #       echo -n "$controller" > /sys/bus/pci/drivers/xhci_hcd/unbind
  #       echo -n "$controller" > /sys/bus/pci/drivers/xhci_hcd/bind
  #     fi
  #   done
  # '';

  # doesn't work because module is built into the kernel so modprobe can't remove it
  # powerManagement.resumeCommands = ''
  #   ${pkgs.kmod}/bin/modprobe -r xhci_pci
  #   ${pkgs.kmod}/bin/modprobe xhci_pci
  # '';

  # user packages on this device
  users.users."${userName}" = {
    packages = with pkgs; [
      unstable.ollama-vulkan
    ];
  };

  # stop charging at 80% to preserve battery health
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", KERNEL=="macsmc-battery", ATTR{charge_control_end_threshold}="80"
  '';

  services.tailscale.useRoutingFeatures = "client";

  system.autoUpgrade.enable = false;

  system.stateVersion = "25.11";
}
