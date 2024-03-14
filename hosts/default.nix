{ lib, pkgs, ... }:

{
  # imports = [
  #   ./rclone
  # ];
  
  # default packages
  environment.systemPackages = with pkgs; [
    direnv
    git
    htop
    sops
    ssh-to-age
    tmux
    tree
    wget
  ];

  sops = {
    # This will add secrets.yml to the nix store
    # You can avoid this by adding a string to the full path instead, i.e.
    # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
    defaultSopsFile = ./secrets.yaml;
    # This will automatically import SSH keys as age keys
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    # This is using an age key that is expected to already be in the filesystem
    age.keyFile = "/var/lib/sops-nix/key.txt";
    # This will generate a new key if the key specified above does not exist
    age.generateKey = true;
    # This is the actual specification of the secrets.
    secrets.sshpub_igor = {
      neededForUsers = true;
    };
  };
  
  # default services  
  services.tailscale.enable = lib.mkDefault true;

  # Auto system update
  system.autoUpgrade = {
        enable = true;
        allowReboot = true;
        rebootWindow = {
          lower = "03:00";
          upper = "06:00";
        };
        flags = [
          "--impure"
        ];
        flake = "github:nikolarobottesla/infra-nix-config";
        dates = "daily";
        randomizedDelaySec = "45min";
  };

  # Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}