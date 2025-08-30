{
  config,
  lib,
  pkgs,
  ... }:
with lib; let
  cfg = config.my.desktop-base;
in {
  options.my.desktop-base = {
    enable = mkEnableOption "enable desktop-base";

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
        brave
        ente-desktop
        gh # github cli
        hunspell # spell check in libreoffice
        hunspellDicts.en_US # english dict
        libreoffice-fresh
        kdePackages.kdeconnect-kde
        nextcloud-client
        rclone
        vlc
      ];
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      kdePackages.kate
      ntfs3g
      snapper-gui # needs services.snapper... to work
    ];

    # programs.appimage = {
    #   enable = true;
    #   binfmt = true;
    # };

    programs.chromium = {
      enable = true;
      # package = pkgs.ungoogled-chromium;  # home-manager only
      # also ungoogled-chromium doesn't seem to work with programs.chromium
    };
    programs.chromium.extensions = [
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      "ldpochfccmkkmhdbclfhpagapcfdljkj" # Decentraleyes
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

    # List services that you want to enable:

    services.duplicati = {
      enable = true;
      user = cfg.userName;
    };

    services.flatpak = {
      enable = true;
      packages = [
        "com.google.Chrome"
        "org.mozilla.firefox"
        "com.github.zocker_160.SyncThingy"
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

    # automated home btrfs snapshots
    my.snapper = {
      enable = true;
      subvolume = "home";
      user = cfg.userName;
    };

  };
}
