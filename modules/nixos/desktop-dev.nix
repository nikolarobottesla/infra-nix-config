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

    programs.chromium.extensions = [
      "kcgpggonjhmeaejebeoeomdlohicfhce" # Cookie Remover
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
      # "aapbdbdomjkkjkaonfhkkikfgjllcleb" # Google Translate
      "fihnjjcciajhdojfnbdddfaoknhalnja" # I don't care about cookies
      # "cimiefiiaegbelhefglklhhakcgmhkai" # Plasma integration
      # "hlepfoohegkhhmjieoechaddaejaokhf" # Refined GitHub
      # "hipekcciheckooncpjeljhnekcoolahp" # Tabliss
    ];

    programs.mtr.enable = true; # network diagnostic tool combining ping and traceroute

    programs.partition-manager.enable = true;  # run with 'sudo partitionmanager'

    # List services that you want to enable:

    services.flatpak = {
      packages = [
        "com.calibre_ebook.calibre"
        "io.freetubeapp.FreeTube"
        # "it.mijorus.gearlever"  # app image manager, check nixpkgs for the app you want instead
        "io.gpt4all.gpt4all"
        "com.github.iwalton3.jellyfin-media-player"
        "io.podman_desktop.PodmanDesktop"
      ];
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
