{
  config,
  inputs,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports =
  [ (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "ohci_pci" "ehci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.kernelParams = [ "mitigations=off" "clearcpuid=rdseed" ];
  boot.extraModulePackages = [ ];

  environment.systemPackages = with pkgs; [
    amdgpu_top
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = lib.mkDefault true;

  hardware.bc250 = {
    enable = true;
    features = {
      # Disabled by default
      cuLiveManager.enable = false;
      cpuOverclock.enable = true;
      cpuOverclock.configFile = ./overclock.conf;
      # Modded BIOSes may already provide their own ACPI fixes, so to avoid
      # conflicts, check first and either turn those off in the BIOS setup
      # or leave this disabled.
      acpiFix.enable = true;

      # Enabled by default
      sensors.enable = true;
      gpuGovernor.enable = true;
      zswap.enable = true;
    };
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;  # Should be enabled by wayland
    enable32Bit = true;  # default is false
  };

  programs.coolercontrol.enable = lib.mkDefault true;

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
  };
}
