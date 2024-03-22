{ lib, pkgs, ... }:
{
  imports = [
    ./actualbudget.nix
    ./auto-update.nix
    ./create_ap.nix
    ./jellyfin.nix
    ./nextcloud.nix
    ./nginx.nix
    ./remote-install.nix
    ./semi-active-av.nix
    ./snapper.nix
    ./tailscale-tls.nix
    ./user.nix
  ];

  # enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
    
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
    # secrets.sshpub_igor = {
    #   neededForUsers = true;
    # };
  };
  
  # default services

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    #settings.PermitRootLogin = "yes";
  };

  services.tailscale.enable = lib.mkDefault true;

  my.auto-update.enable = lib.mkDefault true;

  # Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}