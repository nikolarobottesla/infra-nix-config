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

    # Enable the Plasma 6 Desktop Environment.
    # https://github.com/NixOS/nixpkgs/issues/363797#issuecomment-2558384445
    services.displayManager.sddm.enable = true;  # needed or else login screen is just nix icon and you have to type blind
    services.displayManager.sddm.wayland.enable = true; # fix plasma login freeze, see above
    services.desktopManager.plasma6.enable = true;
    services.displayManager.defaultSession = "plasma"; # uses wayland
    # disable KDE indexer because it's preventing sleep
    # https://github.com/NixOS/nixpkgs/issues/63489
    environment = {
      etc."xdg/baloofilerc".source = (pkgs.formats.ini {}).generate "baloorc" {
        "Basic Settings" = {
          "Indexing-Enabled" = false;
        };
      };
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;
    # Enable autodiscovery of network printers
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Enable sound
    # rtkit is optional but recommended
    # security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };

    # enable bluetooth
    hardware.bluetooth.settings = {
      General = {
        Enable = "Source,Sink,Media,Socket"; # Enabling A2DP Sink
        Experimental = true; # Showing battery charge of bluetooth devices
      };
    };
    hardware.bluetooth.enable = true; # enables support for Bluetooth
    hardware.bluetooth.powerOnBoot = true; # default Bluetooth controller on boot
    
    #logitech wireless peripherals
    hardware.logitech.wireless.enable = true;
    hardware.logitech.wireless.enableGraphical = true;

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;

    my.user.userName = cfg.userName;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users."${cfg.userName}" = {
      extraGroups = ["wheel"]; # wheel enables ‘sudo’ for the user.
      packages = with pkgs; [
        _7zz  # 7zip
        # autorestic  # declarative backup
        chromium
        clementine
        gimp-with-plugins
        heroic
        (heroic.override {
          extraPkgs = pkgs: [
            pkgs.gamescope
            pkgs.gamemode
          ];
        })
        hunspell # spell check in libreoffice
        hunspellDicts.en_US # english dict
        lapce
        libreoffice-fresh
        kdePackages.kdeconnect-kde
        # logseq  # 20240906 - uses EOL electron version
        # miraclecast  # CLI Wifi-Display/Miracast implementation
        nextcloud-client
        protonup-qt
        rclone
        rpi-imager
        # restic
        # simplex-chat-desktop
        strawberry
        # timeshift
        vlc
        # xboxdrv # original xbox/xbox360 userspace driver
      ];
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      clinfo  # graphics
      glxinfo  # graphics
      hddtemp
      iotop
      kdePackages.kate
      mangohud # add 'mangohud %command%' to steam launch option
      ntfs3g
      # playonlinux
      podman-compose
      powershell
      # partition-manager
      quickemu
      # quickgui
      qemu_full
      # (quickemu.override { qemu = qemu_full; })  # this isn't working anymore, gives anonymous lambda error
      # rclone # needs to be systemPackage for systemd.mounts
      unstable.rkdeveloptool-pine64
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

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    programs.mtr.enable = true; # network diagnostic tool combining ping and traceroute

    # nix-gaming cache
    nix.settings = {
      substituters = ["https://nix-gaming.cachix.org"];
      trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
    };

    programs.partition-manager.enable = true;  # run with 'sudo partitionmanager'
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      gamescopeSession.enable = true;
    };

    programs.gamescope.enable = true;

    # To make sure Steam starts a game with GameMode, right click the game, 
    # select Properties..., then Launch Options and enter:
    # gamemoderun %command%
    programs.gamemode = {
      enable = true;
      settings.custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
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
        "com.github.tchx84.Flatseal"
        "io.freetubeapp.FreeTube"
        "io.gpt4all.gpt4all"
        "com.github.iwalton3.jellyfin-media-player"
        "md.obsidian.Obsidian"
        "io.podman_desktop.PodmanDesktop"
        "com.github.Matoking.protontricks"
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

    # used for quickemu file sharing
    services.samba.enable = true;

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

    services.udev.packages = [
      pkgs.yubikey-personalization
    ];

  };
}
