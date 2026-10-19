{
  config,
  lib,
  pkgs,
  ... }:
with lib; let
  cfg = config.my.dev;
in {
  options.my.dev = {
    enable = mkEnableOption "enable developer";

    userName = mkOption {
      type = types.str;
      description = "defaults to nixos";
      default = "nixos";
    };

  };

  config = mkIf cfg.enable {

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users."${cfg.userName}" = {
      # extraGroups = []; # wheel enables ‘sudo’ for the user.
      packages = with pkgs; [
        devenv
        direnv
        unstable.opencode
        # unstable.radicle-tui # decentralized git tui
        unstable.rtk
        unstable.vulnix  # CVE scanner for nix
      ];
    };

    programs.mtr.enable = true; # network diagnostic tool combining ping and traceroute

  };
}
