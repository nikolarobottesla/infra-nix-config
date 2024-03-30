{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.user;
in {
  options.my.user = {

    userName = mkOption {
      type = types.str;
      description = "defaults to nixos";
      default = "nixos";
    };

    hashedPassFile = mkOption {
      type = types.nullOr types.str;
      description = "hashed password file";
      default = null;
    };

  };

  config = {

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.main = {
      name = cfg.userName;
      isNormalUser = true;
      hashedPasswordFile = cfg.hashedPassFile;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      # Add ssh authorized key
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOC+HHp89/1OdTo5dEiBxE3knDSCs9WDg6qIXPitBC83 15TH-TURTLE"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOS1McHV3eQlmmVRyYpjfN2bnAeuIjbyYfDMcPOC8JWO nix"
      ];
    };

  };
}