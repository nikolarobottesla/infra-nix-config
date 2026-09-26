{ config, home-manager, inputs, lib, options, pkgs, ... }:
let
  hostName = "oak-1";
  userName = "deer";
  domain = "${hostName}.stork-galaxy.ts.net";
  # Private public domain. Read at build time from an untracked file so the
  # literal never appears in this repo. Rebuild needs `--impure`.
  # sudo echo '<string>' | sudo tee /etc/nixos/<file>
  baseDomain = lib.trim (builtins.readFile /etc/nixos/nps-domain);
  acmeEmail = lib.trim (builtins.readFile /etc/nixos/acme-email);
  userMnt = "/home/${userName}/mnt";
  arrayMnt = "/srv/array0";
  serviceData = "${arrayMnt}/services";
  # script to update podman containers
  # TODO add service to run this periodically, move this and other podman stuff into a module
  update-containers = pkgs.writeShellScriptBin "update-containers" ''
    SUDO=""
    if [[ $(id -u) -ne 0 ]]; then
      SUDO="sudo"
    fi

      images=$($SUDO ${pkgs.podman}/bin/podman ps -a --format="{{.Image}}" | sort -u)

      for image in $images
      do
        $SUDO ${pkgs.podman}/bin/podman pull $image
      done

      $SUDO ${pkgs.podman}/bin/podman restart --all
  '';
in
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko-config.nix
    ./hardware-configuration.nix
    ./samba.nix
    ./syncthing.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  # enable clamav with services
  # semi-active-av.enable = true;

  networking.hostName = "${ hostName }"; # Define your hostname.
  networking.wireless.enable = lib.mkForce false;
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    # font = "Lat2-Terminus16";
    keyMap = "us";
  };

  nixpkgs.config.allowUnfree = true;

  # sops.secrets = {
  #   smb-secrets = {
  #     sopsFile = ./secrets.yaml;
  #   };
  # };

  # for mounting previous server share
  # fileSystems."${userSrv}/<server host name>/media" = {
  #   device = "//<server host name>/media";
  #   fsType = "cifs";
  #   options = let
  #     # this line prevents hanging on network split
  #     automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

  #   in ["${automount_opts},credentials=${config.sops.secrets.smb-secrets.path}"];
  # };
  
  # https://www.freedesktop.org/software/systemd/man/tmpfiles.d
  systemd.tmpfiles.rules = [
    # "z /srv/array0 0750 deer users"
    # one of these is needed for nextcloud
    "z ${arrayMnt} 0755 root root"
    "z ${serviceData} 0755 root root"
  ];

  my.user.userName = userName;

  sops.secrets = {
    # NPS / Nix Podman Stacks
    "traefik/cf_api_token" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    "authelia/jwt_secret" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    "authelia/session_secret" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    "authelia/encryption_key" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    "authelia/oidc_hmac_secret" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    "authelia/oidc_rsa_pk" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    "lldap/admin_password" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    "lldap/jwt_secret" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    "lldap/key_seed" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    # "lldap/deer_password" = {
    #   sopsFile = ./secrets.yaml;
    #   owner = userName;
    #   group = "users";
    #   mode = "0400";
    # };
    "homepage/auth_secret" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    "homepage/oidc_client_secret" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    "paperless/oidc_client_secret" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    "paperless/secret_key" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    "paperless/db_password" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    "paperless/admin_password" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    "monitoring/grafana_oidc_client_secret" = {
      sopsFile = ./secrets.yaml;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    "cloudflared-tunnel-token" = {
      sopsFile = ./secrets.yaml;
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  my.nps = {
    enable = true;
    domain = baseDomain;
    hostIP4Address = "127.0.0.1";
    acmeEmail = acmeEmail;
    cloudflared = {
      enable = true;
      tokenFile = config.sops.secrets."cloudflared-tunnel-token".path;
    };
    secrets.traefik.cfDnsApiToken = config.sops.secrets."traefik/cf_api_token".path;
    secrets.authelia.jwtSecret = config.sops.secrets."authelia/jwt_secret".path;
    secrets.authelia.sessionSecret = config.sops.secrets."authelia/session_secret".path;
    secrets.authelia.storageEncryptionKey = config.sops.secrets."authelia/encryption_key".path;
    secrets.authelia.oidc.hmacSecret = config.sops.secrets."authelia/oidc_hmac_secret".path;
    secrets.authelia.oidc.jwksRsaKey = config.sops.secrets."authelia/oidc_rsa_pk".path;
    secrets.lldap.adminPassword = config.sops.secrets."lldap/admin_password".path;
    secrets.lldap.jwtSecret = config.sops.secrets."lldap/jwt_secret".path;
    secrets.lldap.keySeed = config.sops.secrets."lldap/key_seed".path;
    # secrets.lldap.deerPassword = config.sops.secrets."lldap/deer_password".path;
    secrets.homepage.authSecret = config.sops.secrets."homepage/auth_secret".path;
    secrets.homepage.oidcClientSecret = config.sops.secrets."homepage/oidc_client_secret".path;
    secrets.paperless.oidcClientSecret = config.sops.secrets."paperless/oidc_client_secret".path;
    secrets.paperless.secretKey = config.sops.secrets."paperless/secret_key".path;
    secrets.paperless.dbPassword = config.sops.secrets."paperless/db_password".path;
    secrets.paperless.adminPassword = config.sops.secrets."paperless/admin_password".path;
    secrets.monitoring.grafanaOidcClientSecret = config.sops.secrets."monitoring/grafana_oidc_client_secret".path;
  };

  home-manager.users."${userName}" = lib.mkMerge [
    (import ../../home-manager/home.nix)
    {
      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = "23.11";
    }
  ];
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    e2fsprogs
    hddtemp
    iotop
    podman-compose
    podman-tui
    smartmontools
    update-containers
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

  my.btrbk-client.enable = true;

  my.jellyfin.enable = true;

  # sops.secrets = {
  #   pinepods-admin-pass = {
  #     sopsFile = ./secrets.yaml;
  #   };
  #   pinepods-db-pass = {
  #     sopsFile = ./secrets.yaml;
  #   };
  # };
  # my.pinepods = {
  #   enable = true;
  #   dataDir = "${serviceData}/pinepods";
  #   hostname = "http://${domain}:8040";
  #   dbPassword = "changeme"; # TODO use sops
  #   admin.password = "changeme"; # TODO use sops
  # };

  sops.secrets = {
    nextcloud-admin-pass = {
      sopsFile = ./secrets.yaml;
      mode = "0400";
      owner = "nextcloud";
      group = "nextcloud";
    };
  };
  my.nextcloud = {
    enable = true;
    adminpassFile = config.sops.secrets.nextcloud-admin-pass.path;
    domain = domain;
  };
  # allow nextcloud to read syncthing files
  users.users.nextcloud.extraGroups = [ config.services.syncthing.group ];
  
  my.nginx = {
    enable = true;
    domain = domain;
  };

  my.cockpit = {
    enable = true;
    domain = domain;
  };

  my.code-server = {
    enable = true;
    userName = userName;
    host = domain;
    hashedPassword = "$argon2i$v=19$m=4096,t=3,p=1$TU1ySTRTZWRvL3dTaHdsclp1Zm9TZlNVUzhBPQ$s4DNlVzUU0o+TWY84mc9WcFF356mUep1IaQuL0e6f8k";
  };
  
  # samba
  my.samba-server = {
    enable = true;
    userName = userName;
  };

  sops.secrets = {
    syncthing-cert = {
      sopsFile = ./secrets.yaml;
      mode = "0400";
      owner = "syncthing";
      group = "syncthing";
    };
    syncthing-key = {
      sopsFile = ./secrets.yaml;
      mode = "0400";
      owner = "syncthing";
      group = "syncthing";
    };
  };
  my.syncthing = {
    enable = true;
    cert = config.sops.secrets.syncthing-cert.path;
    key = config.sops.secrets.syncthing-key.path;
  };

  services.tailscale.useRoutingFeatures = "server";

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

      # remove unused images 
      autoPrune = {
        enable = true;
        flags = [ "--all" ];
      };
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
