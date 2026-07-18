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
  boot.kernel.sysctl = { "vm.swappiness" = 180;};
  boot.zswap.enable = true;
  boot.zswap.compressor = "lz4";
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = lib.mkDefault true;

  # This will save you money and possibly your life!
  services.thermald.enable = lib.mkDefault true;

  hardware.bc250 = {
    enable = true;
    features = {
      # Disabled by default
      aic8800d80.enable = false;
      cuLiveManager.enable = false;

      # Enabled by default
      sensors.enable = true;
      governor.enable = true;
      zram.enable = false;
    };
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;  # Should be enabled by wayland
    enable32Bit = true;  # default is false
  };

}
