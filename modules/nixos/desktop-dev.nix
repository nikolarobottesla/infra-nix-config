{
  config,
  lib,
  pkgs,
  ... }:
with lib; let
  cfg = config.my.desktop-dev;
in {
  options.my.desktop-dev = {
    enable = mkEnableOption "enable desktop";

    userName = mkOption {
      type = types.str;
      description = "defaults to nixos";
      default = "nixos";
    };

    homeStateVersion = mkOption {
      type = types.str;
      description = "defaults to 23.11";
      default = "23.11";
    };

  };

  config = mkIf cfg.enable {

    my.user.userName = cfg.userName;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users."${cfg.userName}" = {
      extraGroups = ["adbusers" "libvirtd"]; # wheel enables ‘sudo’ for the user.
      packages = with pkgs; [
        brave
        # chromium
        # clementine
        devenv
        gh # github cli
        gimp-with-plugins
        discord
        lapce
        kdePackages.kdeconnect-kde
        # miraclecast  # CLI Wifi-Display/Miracast implementation
        rpi-imager
        # restic
        strawberry
        # timeshift
        yubioath-flutter
      ];
    };

    home-manager.users."${cfg.userName}" = lib.mkMerge [
      (import ../../home-manager/home.nix)
      (import ../../home-manager/desktop.nix)
      {
        # The state version is required and should stay at the version you
        # originally installed.
        home.stateVersion = cfg.homeStateVersion;
      }
    ];

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      clinfo  # graphics
      glxinfo  # graphics
      hddtemp
      iotop
      podman-compose
      powershell
      # partition-manager
      quickemu
      # quickgui
      qemu_full
      # (quickemu.override { qemu = qemu_full; })  # this isn't working anymore, gives anonymous lambda error
      # rclone # needs to be systemPackage for systemd.mounts
      # unstable.rkdeveloptool-pine64
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

    programs.partition-manager.enable = true;  # run with 'sudo partitionmanager'

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
        # "it.mijorus.gearlever"  # app image manager, check nixpkgs for the app you want instead
        "io.gpt4all.gpt4all"
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

    # needed for yubikey
    services.pcscd.enable = true;

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
      pkgs.android-udev-rules
      pkgs.yubikey-personalization
    ];

    # enable libvirt and virt-manager
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    # for networking have to run `sudo virsh net-autostart default' once
    # https://nixos.wiki/wiki/Virt-manager

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
