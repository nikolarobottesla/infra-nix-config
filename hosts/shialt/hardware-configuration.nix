{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernel.sysctl = { "vm.swappiness" = 10;};
  boot.extraModulePackages = [ ];

  # TODO remove once on a new kernel
  # audio fix for kernel 6.6.46
  boot.extraModprobeConfig =''
    options snd-hda-intel dmic_detect=0
  '';

  # TODO: try and then move to nixos-hardware if it is good
  # boot = {
  #   # Divides power consumption by two.
  #   kernelParams = [ "acpi_osi=" ];
  # };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp58s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = lib.mkDefault true;

  # This will save you money and possibly your life!
  services.thermald.enable = lib.mkDefault true;

  # thunderbolt package for plasma
  environment.systemPackages = with pkgs; [
    kdePackages.plasma-thunderbolt
  ];

  # thunderbolt dock service
  services.hardware.bolt.enable = true;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;  # Should be enabled by wayland
    driSupport32Bit = true;  # default is false, only supported by nvidia/mesa
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;  # when true seems to play in game videos better

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	  # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    prime = {
      sync.enable = true;
      # reverseSync.enable = true;  # seemed to be worse graphically, steam won't show GUI
      # Make sure to use the correct Bus ID values for your system!
      # sudo lshw -c display
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
