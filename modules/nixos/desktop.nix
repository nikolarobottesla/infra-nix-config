{
  config,
  lib,
  pkgs,
  ... }:

with lib; let
  cfg = config.my.desktop;
in {
  options.my.desktop = {
    enable = mkEnableOption "enable desktop";

    userName = mkOption {
      type = types.str;
      description = "defaults to nixos";
      default = "nixos";
    };

  };

  config = mkIf cfg.enable {

    boot.loader.efi.canTouchEfiVariables = true;
    boot.supportedFilesystems = ["ntfs"];

    # seems to build faster with it commented in
    boot.binfmt.emulatedSystems = ["aarch64-linux"]; # not sure if it's needed for flake method

    # enable clamav with services
    semi-active-av.enable = true;

    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

    my.dns.enable = lib.mkDefault true;

    # Set your time zone.
    services.automatic-timezoned.enable = true;

    # failed to build when rebuilding from nixos-enter and root
    # comment out after booted directly
    # services.logrotate.checkConfig = false;

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
        font = "Lat2-Terminus16";
        keyMap = "us";
        # useXkbConfig = true; # use xkb.options in tty.
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

    my.user.userName = cfg.userName;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users."${cfg.userName}" = {
      extraGroups = ["wheel" "adbusers"]; # wheel enables ‘sudo’ for the user.
      packages = with pkgs; [
        # autorestic  # declarative backup
        chromium
        hunspell # spell check in libreoffice
        hunspellDicts.en_US # english dict
        lapce
        libreoffice-qt
        libsForQt5.kdeconnect-kde
        # miraclecast  # CLI Wifi-Display/Miracast implementation
        nextcloud-client
        rclone
        rpi-imager
        # restic
        # timeshift
        vlc
      ];
    };

    home-manager.users."${cfg.userName}" = lib.mkMerge [
      (import ../../home-manager/home.nix)
      (import ../../home-manager/desktop.nix)
      {
        # The state version is required and should stay at the version you
        # originally installed.
        home.stateVersion = "23.11";
      }
    ];

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      clinfo  # graphics
      glxinfo  # graphics
      hddtemp
      iotop
      kate
      ntfs3g
      # playonlinux
      podman-compose
      # partition-manager
      # rclone # needs to be systemPackage for systemd.mounts
      snapper-gui # needs services.snapper... to work
      steam-run  # FHS env
      tailscale
      vulkan-tools  # graphics
      wayland-utils  # graphics
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

    programs.chromium = {
      enable = true;
      # package = pkgs.ungoogled-chromium;  # home-manager only
      # also ungoogled-chromium doesn't seem to work with programs.chromium
    };
    programs.chromium.extensions = [
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      "kcgpggonjhmeaejebeoeomdlohicfhce" # Cookie Remover
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
      "ldpochfccmkkmhdbclfhpagapcfdljkj" # Decentraleyes
      # "aapbdbdomjkkjkaonfhkkikfgjllcleb" # Google Translate
      "fihnjjcciajhdojfnbdddfaoknhalnja" # I don't care about cookies
      # "cimiefiiaegbelhefglklhhakcgmhkai" # Plasma integration
      # "hlepfoohegkhhmjieoechaddaejaokhf" # Refined GitHub
      # "hipekcciheckooncpjeljhnekcoolahp" # Tabliss
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
    ];
    programs.chromium.extraOpts = {  # 
      DefaultBrowserSettingEnabled = true;

      # TranslateEnabled = false;
      # SpellcheckEnabled = false;
      # SpellCheckServiceEnabled = false;
      # PrintingEnabled = false;
      # SearchSuggestEnabled = false;
      PasswordManagerEnabled = false;
      # SafeBrowsingEnabled  = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      MetricsReportingEnabled = false;
      BuiltInDnsClientEnabled = false;
      # EnableMediaRouter = false;
      PromotionalTabsEnabled = false;
      # SyncDisabled = true;
      # SigninAllowed = false;
      # AudioCaptureAllowed = false;
      # VideoCaptureAllowed = false;
      # SSLErrorOverrideAllowed = false;
      # AutoplayAllowed = false;

      # 0 = Disable browser sign-in
      # BrowserSignin = 0;

      #DefaultSearchProviderEnabled = true;
      #DefaultSearchProviderSearchURL = "https://duckduckgo.com/"
      #+ "?kae=d&k1=-1&kc=1&kav=1&kd=-1&kh=1&q={searchTerms}";

      # Do not allow any site to show desktop notifications
      DefaultNotificationsSetting = 2;
      # Do not allow any site to track the users' physical location
      DefaultGeolocationSetting = 2;
      # Block the Flash plugin
      DefaultPluginsSetting = 2;
    };

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
      user = cfg.userName;
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

  };
}
