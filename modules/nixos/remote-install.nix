{ config, lib, pkgs, ...  }:
with lib; let
  cfg = config.my.remote-install;
  userName = "nixos";
in {
  options.my.remote-install = {
    enable = mkEnableOption "remote install option";
    
    hostName = mkOption {
      type = types.str;
      description = "hostname";
      default = "fresh-nix";
    };
  };
  
  config =  mkIf cfg.enable {

    console.enable = false;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${userName} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    };

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    networking.hostName = "${ cfg.hostName }"; # Define your hostname.

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOC+HHp89/1OdTo5dEiBxE3knDSCs9WDg6qIXPitBC83 15TH-TURTLE"
    ];

    # # using default instead
    # environment.systemPackages = with pkgs; [
    #   git
    #   htop
    #   iotop
    #   sops
    #   tmux
    #   tree
    #   wget
    # ];

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      # require public key authentication for better security
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      #settings.PermitRootLogin = "yes";
    };
  };
}