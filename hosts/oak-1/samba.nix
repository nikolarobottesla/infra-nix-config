# more complex example https://github.com/bestlem/nixos-configs/tree/main/hosts/x86_64-linux/meteion/samba
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.samba-server;

  smbUserNames = [ "igor" "media" "sauce" ];
  
  smbUsers = lib.genAttrs smbUserNames (name: {
    isSystemUser = true;
    description = "Samba user";
    group = "samba-users";
    shell = pkgs.shadow;
  });

in {
  options.my.samba-server = {
    enable = mkEnableOption "samba server";

    arrayMnt = mkOption {
      type = types.str;
      description = "storage array mount point";
      default = "/srv/array0";
    };

    userName = mkOption {
      type = types.str;
      description = "user name of share owner";
      default = "deer";
    };

    # writeList = mkOption {
    #   type = types.list;
    #   description = "list of write access samba users";
    #   default = [];
    # };

    # passwdFile = mkOption {
    #   type = types.str;
    #   description = "smbpasswd formatted file for import";
    #   default = "";
    # };

  };

  config = mkIf cfg.enable {

    users.groups.samba-users = { };

    # add smb-rw group to rw users
    # users.users = smbUsers // {
    #   igor = smbUsers.igor // {
    #     extraGroups = [ "smb-rw" ];
    #   };
    # };
    users.users = smbUsers;

    sops.secrets.smb-passwd = {
      sopsFile = ./secrets.yaml;
      mode = "400";
    };

    # https://www.samba.org/samba/docs/current/man-html/pdbedit.8.html
    system.activationScripts = lib.mkIf config.services.samba.enable {
      sambaUserSetup = {
        text = ''
          ${pkgs.samba}/bin/pdbedit \
            -i smbpasswd:${config.sops.secrets.smb-passwd.path} \
            -e tdbsam:/var/lib/samba/private/passdb.tdb
          ${pkgs.tailscale}/bin/tailscale serve --bg --tcp 445 tcp://localhost:445
        '';
        deps = [ "setupSecrets" ];
      };
    };

    # https://www.freedesktop.org/software/systemd/man/tmpfiles.d
    systemd.tmpfiles.rules = [
      # "z /srv/array0 0750 deer users"
      # "Z ${cfg.arrayMnt}/media 0775 ${cfg.userName} samba-users"  # ran once in the beginning
      # "Z ${cfg.arrayMnt}/private 0755 ${parent.userName} samba-users"
      # "Z ${cfg.arrayMnt}/private/duplicati 0755 igor samba-users"  # used to allow samba igor to write
    ];
      
    # https://gist.github.com/vy-let/a030c1079f09ecae4135aebf1e121ea6
    services.samba = {
      package = pkgs.samba4Full;
      # ^^ `samba4Full` is compiled with avahi, ldap, AD etc support (compared to the default package, `samba`
      # Required for samba to register mDNS records for auto discovery 
      # See https://github.com/NixOS/nixpkgs/blob/592047fc9e4f7b74a4dc85d1b9f5243dfe4899e3/pkgs/top-level/all-packages.nix#L27268
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          browsable = "yes";
          workgroup = "WORKGROUP";
          security = "user";
          "server string" = config.networking.hostName;
          "netbios name" = config.networking.hostName;
          # "use sendfile" = "yes";
          "server min protocol" = "SMB3";
          # "server smb encrypt" = "required";
          # https://github.com/tailscale/tailscale/issues/6856#issuecomment-1485385748
          # these next 2 are for tailscale
          interfaces = "lo eno1";
          # "bind interfaces only" = "yes"; # doesn't seem to be an available option anymore 20241200
          # note: localhost is the ipv6 localhost ::1
          "hosts allow" = "192.168.1.0 127.0.0.1 localhost 100.0";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
        };
        media = {
          path = "${cfg.arrayMnt}/media";
          "read only" = "yes";
          "write list" = "igor";
          # "guest ok" = "no";
          "create mask" = "0664";
          "directory mask" = "0775";
          # "force user" = "deer";
          # "force group" = "users";
        };
        private = {
          path = "${cfg.arrayMnt}/private";
          "valid users" = "igor sauce";
          # "read only" = "no";
          # "guest ok" = "no";
          # "create mask" = "0644";
          # "directory mask" = "0755";
          # "force user" = "deer";
          # "force group" = "users";
        };
      };
    };
    services.avahi = {
      publish.enable = true;
      publish.userServices = true;
      # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
      #nssmdns4 = true;
      # ^^ Not one hundred percent sure if this is needed- if it aint broke, don't fix it
      enable = true;
      openFirewall = true;
    };
    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    networking.firewall.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      cifs-utils  # needed for domain name resolution using cifs(samba)
    ];
  };
}