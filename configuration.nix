# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, options, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";
  # nix2211 = fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-22.11.tar.gz";
  # nix2211Pkgs = import nix2211 { config.allowUnfree = true; }; # if you do need pkgs
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
      ./disko-config.nix
      (import "${home-manager}/nixos")
      ./semi-active-av.nix
    ];

  nix.nixPath = 
    # Prepend default nixPath values!
    options.nix.nixPath.default ++  
    ["nixos-config=/home/igor/code/infra-nix-config/configuration.nix"]
  ;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  # enable clamav with services
  semi-active-av.enable = true;

  networking.hostName = "15TH-TURTLE"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Chicago";

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
      # restic
      timeshift
      vscode
    ];
  };
  home-manager.users.igor = { pkgs, ... }: {
  # home.packages = [ pkgs.atool pkgs.httpie ];
  # programs.bash.enable = true;
    programs.git = {
      enable = true;
      userName  = "nikolarobottesla";
      userEmail = "13294739+nikolarobottesla@users.noreply.github.com";
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
    partition-manager
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

  # comment in after rclone config, make sure to name remote 'pcloud'
  programs.fuse.userAllowOther = true;
  systemd.services.rcpcloudmount = {
    enable = true;
    description = "rclone pcloud mounting service";
    # after = [ "remote-fs.target" ];  # would probably also work
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    # path = [ pkgs.nix pkgs.su pkgs.rclone pkgs.fuse3];
    path = [ pkgs.su ];
    preStart = "su igor -c 'mkdir -p /home/igor/rcpcloud'";
    # script = "rclone mount pcloud: /home/igor/rcpcloud --vfs-cache-mode full --config /home/igor/.config/rclone/rclone.conf --allow-other";
    script = "su igor -c 'rclone mount pcloud: /home/igor/rcpcloud --vfs-cache-mode full --allow-other'";
    preStop = "su igor -c 'fusermount -u /home/igor/rcpcloud'";
    postStop = "su igor -c 'rmdir /home/igor/rcpcloud'";

    restartIfChanged = true;  # doesn't seem to do anything
    restartTriggers = [ "on-failure" ]; # doesn't seem to work
    serviceConfig = {
      Type = "simple";
      # Environment = "PATH=$PATH:${lib.makeBinPath [ pkgs.coreutils pkgs.rclone pkgs.fuse3 ]}";  # didn't seem to work
      # User = "igor"; # this works to give the user env but then the script had a permissions isssue
      # Restart = "on-failure"; 
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # enable snapper (btrfs snapshots)
  # manually create 'sudo btrfs subvolume create /home/.snapshots'
  services.snapper.snapshotInterval = "1d";
  services.snapper.configs.home = {
    SUBVOLUME = "/home";
    ALLOW_USERS = [ "igor" ];
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_MIN_AGE="1800";
    TIMELINE_LIMIT_HOURLY="0";
    TIMELINE_LIMIT_DAILY="3";
    TIMELINE_LIMIT_WEEKLY="3";
    TIMELINE_LIMIT_MONTHLY="1";
    TIMELINE_LIMIT_YEARLY="0";
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

