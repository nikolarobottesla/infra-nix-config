{
  config,
  home-manager,
  inputs,
  lib,
  pkgs,
  options,
  ...
}: let
  device-name = "15TH-TURTLE";
  userName = "igor";
in {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.hp-elitebook-830-g6
    inputs.nix-flatpak.nixosModules.nix-flatpak
    ./disko-config.nix
    ./hardware-configuration.nix
    # comment in after rclone config
    (import ../../modules/rclone {
      userName = userName;
      remote-name = "pcloud";
    })
    (import ../../modules/rclone {
      userName = userName;
      remote-name = "onedrive";
    })
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["ntfs"];

  # seems to build faster with it commented in
  boot.binfmt.emulatedSystems = ["aarch64-linux"]; # not sure if it's needed for flake method

  # enable clamav with services
  semi-active-av.enable = true;

  networking.hostName = "${device-name}"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

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
  services.xserver.displayManager.defaultSession = "plasmawayland"; # seems to use wayland no matter what
  # disable KDE indexer because it's preventing sleep
  # https://github.com/NixOS/nixpkgs/issues/63489
  environment = {
    etc."xdg/baloofilerc".source = (pkgs.formats.ini {}).generate "baloorc" {
      "Basic Settings" = {
        "Indexing-Enabled" = false;
      };
    };
  };

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
  hardware.pulseaudio.package = pkgs.pulseaudioFull; # more bluetooth codecs
  hardware.pulseaudio.extraConfig = "
    load-module module-switch-on-connect
  "; # auto switch to BT audio on connect

  # enable bluetooth
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket"; # Enabling A2DP Sink
      Experimental = true; # Showing battery charge of bluetooth devices
    };
  };
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # default Bluetooth controller on boot

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.permittedInsecurePackages = [
  #   "electron-25.9.0"  # needed for obsidian on 20240101
  # ];

  my.user.userName = userName;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${userName}" = {
    extraGroups = ["wheel" "adbusers"]; # wheel enables ‘sudo’ for the user.
    packages = with pkgs; [
      # autorestic  # declarative backup
      hunspell # spell check in libreoffice
      hunspellDicts.en_US # english dict
      lapce
      libreoffice-qt
      libsForQt5.kdeconnect-kde
      rclone
      rpi-imager
      # restic
      # timeshift
      vlc
    ];
  };

  home-manager.users."${userName}" = lib.mkMerge [
    (import ../../home.nix)
    {
      # home.packages = [ pkgs.atool pkgs.httpie ];
      # programs.bash.enable = true;
      programs.chromium = {
        enable = true;
        package = pkgs.ungoogled-chromium;
      };
      programs.firefox.enable = true;
      programs.vscode = {
        enable = true;
        extensions = with pkgs.vscode-extensions; [
          bbenoist.nix
          ms-python.python # pylance and debugger
          # ms-vscode.remote-explorer # not available
          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-ssh
          # ms-vscode.remote-server # not available
          yzhang.markdown-all-in-one
        ];
        # package = pkgs.vscode.fhs;  # if enabled, server needs special treatment
      };

      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = "23.11";
    }
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    htop
    hddtemp
    iotop
    kate
    ntfs3g
    podman-compose
    # partition-manager
    # rclone # needs to be systemPackage for systemd.mounts
    snapper-gui # needs services.snapper... to work
    tailscale
  ];

  environment = {
    variables = {
      EDITOR = "code --wait";
      SYSTEMD_EDITOR = "code --wait";
      # VISUAL = "code --wait";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.

  # android platform tools
  programs.adb.enable = true;
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  programs.mtr.enable = true; # network diagnostic tool combining ping and traceroute
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  };

  # List services that you want to enable:

  services.duplicati = {
    enable = true;
    user = userName;
  };

  services.flatpak = {
    enable = true;
    packages = [
      "com.calibre_ebook.calibre"
      "org.clementine_player.Clementine"
      "com.github.tchx84.Flatseal"
      "io.freetubeapp.FreeTube"
      "com.github.iwalton3.jellyfin-media-player"
      "md.obsidian.Obsidian"
      "io.podman_desktop.PodmanDesktop"
      "com.github.zocker_160.SyncThingy"
      "dev.deedles.Trayscale" # not working
    ];
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # automated home btrfs snapshots
  my.snapper = {
    enable = true;
    subvolume = "home";
  };

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
    waydroid.enable = false;
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
