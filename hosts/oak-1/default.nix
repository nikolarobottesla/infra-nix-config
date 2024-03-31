{ config, home-manager, inputs, lib, options, pkgs, ... }:
let
  hostName = "oak-1";
  userName = "deer";
  userSrv = "/home/${userName}/srv";
  arrayMnt = "/srv/array0";
  serviceData = "${arrayMnt}/services";
in
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko-config.nix
    ./hardware-configuration.nix
    ./samba.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  # enable clamav with services
  # semi-active-av.enable = true;

  networking.hostName = "${ hostName }"; # Define your hostname.
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;  # often fails on rebuild switch

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    # font = "Lat2-Terminus16";
    keyMap = "us";
  };

  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.permittedInsecurePackages = [
  #   "electron-25.9.0"  # needed for obsidian on 20240101
  # ];
  sops.secrets = {
    smb-secrets = {
      sopsFile = ./secrets.yaml;
    };
  };

  fileSystems."${userSrv}/wochat/media" = {
    device = "//WOCHAT-NAS/media";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},credentials=${config.sops.secrets.smb-secrets.path}"];
  };
  fileSystems."${userSrv}/wochat/private" = {
    device = "//WOCHAT-NAS/private";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},credentials=${config.sops.secrets.smb-secrets.path}"];
  };
  
  # https://www.freedesktop.org/software/systemd/man/tmpfiles.d
  systemd.tmpfiles.rules = [
    # "z /srv/array0 0750 deer users"
    # one of these is needed for nextcloud
    "z ${arrayMnt} 0755 root root"
    "z ${serviceData} 0755 root root"
  ];

  my.user.userName = userName;

  home-manager.users.main = { pkgs, ... }: {
    # home.packages = [ pkgs.atool pkgs.httpie ];
    # programs.bash.enable = true;

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "23.11";
  };
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cifs-utils  # needed for domain name resolution using cifs(samba)
    e2fsprogs
    hddtemp
    iotop
    podman-compose
    smartmontools
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.

  programs.mtr.enable = true;  # network diagnostic tool combining ping and traceroute
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/srv" ];  # only scrub here
  };

  my.actualbudget = {
    enable = true;
    dataDir = "${serviceData}/actualbudget";
    sslCertificate = "${config.my.tailscale-tls.certDir}/cert.crt";
    sslCertificateKey = "${config.my.tailscale-tls.certDir}/key.key";
  };

  my.jellyfin.enable = true;

  sops.secrets = {
    nextcloud-admin-pass = {
      sopsFile = ./secrets.yaml;
      mode = "0440";
      owner = "nextcloud";
      group = "nextcloud";
    };
  };
  my.nextcloud = {
    enable = true;
    adminpassFile = config.sops.secrets.nextcloud-admin-pass.path;
  };

  my.openvscode-server.enable = true;

  # samba
  my.samba-server = {
    enable = true;
    userName = userName;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  virtualisation = {
    oci-containers.backend = "podman";
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
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
