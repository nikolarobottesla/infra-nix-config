# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, options, home-manager, ... }:
let
  device-name = "15TH-TURTLE";
  user-name = "igor";
  # rclone-config = "/home/${user-name}/.config/rclone/rclone.conf";
  # rclone-mount-options = "rw,_netdev,allow_other,args2env,vfs-cache-mode=full,allow_non_empty,config=${rclone-config}";
in
{
  imports =
    [
      ./devices/${device-name}.nix
      ./disko-config.nix
      (import ./home-manager { user-name = user-name; })
      # comment in after rclone config
      (import ./modules/rclone { user-name = user-name; remote-name = "pcloud"; })
      (import ./modules/rclone { user-name = user-name; remote-name = "onedrive"; })
      ./semi-active-av.nix
    ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  # needed to build for pi
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];  # not sure if it's needed for flake method

  # enable clamav with services
  semi-active-av.enable = true;

  networking.hostName = "${device-name}"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  services.automatic-timezoned.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
#     useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";  # doesn't seem to work

  # Configure keymap in X11
#   services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Enable autodiscovery of network printers
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.permittedInsecurePackages = [
  #   "electron-25.9.0"  # needed for obsidian on 20240101
  # ];


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.igor = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # wheel enables ‘sudo’ for the user.
    packages = with pkgs; [
      # authy
      # autorestic  # declarative backup
      # clementine
      firefox
      hunspell  # spell check in libreoffice
      hunspellDicts.en_US  # english dict
      libreoffice-qt 
      libsForQt5.kdeconnect-kde
      # obsidian
      rclone
      rpi-imager
      # restic
      # timeshift
    ];
  };
  home-manager.users.igor = { pkgs, ... }: {
  # home.packages = [ pkgs.atool pkgs.httpie ];
  # programs.bash.enable = true;
    programs.vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.11";
  };
  

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    htop
    hddtemp
    iotop
    kate
    # partition-manager
    # rclone # needs to be systemPackage for systemd.mounts
    snapper-gui  # needs services.snapper... to work
    tailscale
    tmux
    tree
    vim
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.

  programs.mtr.enable = true;  # network diagnostic tool combining ping and traceroute
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };

  services.duplicati = {
    enable = true;
    user = "igor";
  };
  services.flatpak.enable = true;
  services.tailscale.enable = true;

  # # comment in after rclone config, make sure to name remote 'pcloud'
  # programs.fuse.userAllowOther = true;
  # systemd.services.rclonemount = {
  #   enable = true;
  #   description = "rclone mounting service";
  #   # after = [ "remote-fs.target" ];  # would probably also work
  #   after = [ "network-online.target" ];
  #   wantedBy = [ "multi-user.target" ];

  #   path = [ pkgs.su ];
  #   preStart = "${su-c} 'mkdir -p /home/${user-name}/rcpcloud'";
  #   script = "${su-c} 'rclone mount pcloud: /home/${user-name}/rcpcloud --vfs-cache-mode full --allow-other --allow-non-empty'";
  #   preStop = "${su-c} 'fusermount -u /home/${user-name}/rcpcloud'";
  #   postStop = "${su-c} 'rmdir /home/${user-name}/rcpcloud'";

  #   restartIfChanged = true;  # doesn't seem to do anything
  #   restartTriggers = [ "on-failure" ]; # doesn't seem to work
  #   serviceConfig = {
  #     Type = "simple";
  #     # Environment = "PATH=$PATH:${lib.makeBinPath [ pkgs.coreutils pkgs.rclone pkgs.fuse3 ]}";  # didn't seem to work
  #     # User = "igor"; # this works to give the user env but then the script had a permissions isssue
  #     # Restart = "on-failure"; 
  #   };
  # };
  # couldn't get this to work, user didn't have access
  # systemd.mounts = [
  #   {
  #     description = "rclone ondrive mount";
  #     what = "onedrive:";
  #     where = "/home/${user-name}/onedrive";
  #     type = "rclone";
  #     options = "${ rclone-mount-options }";
  #   }
  # ];
  # systemd.automounts = [
  #   {
  #     description = "rclone onedrive automount";
  #     where = "/home/${user-name}/onedrive";
  #     wantedBy = [ "multi-user.target" ];
  #   }
  # ];


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # enable snapper (btrfs snapshots)
  # manually create 'sudo btrfs subvolume create /home/.snapshots'
  #TODO get working
  services.snapper.snapshotInterval = "1d";
  services.snapper.configs.home = {
    SUBVOLUME = "/home";
    ALLOW_USERS = [ "igor" ];
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_MIN_AGE="1800";
    # TIMELINE_LIMIT_HOURLY="0";
    TIMELINE_LIMIT_DAILY="3";
    TIMELINE_LIMIT_WEEKLY="3";
    TIMELINE_LIMIT_MONTHLY="1";
    TIMELINE_LIMIT_YEARLY="0";
  };

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Auto system update
  system.autoUpgrade = {
        enable = true;
  };

  # Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

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

