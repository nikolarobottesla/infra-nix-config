{
  config,
  lib,
  pkgs,
  ... }:
with lib; let
  cfg = config.my.gaming;
in {
  options.my.gaming = {
    enable = mkEnableOption "enable gaming";

    userName = mkOption {
      type = types.str;
      description = "defaults to nixos";
      default = "nixos";
    };
  };

  config = mkIf cfg.enable {
          
    users.users."${cfg.userName}" = {
      extraGroups = ["gamemode"];
      packages = with pkgs; [
        # 20250521 using EOL electron
        # heroic
        # (heroic.override {
        #   extraPkgs = pkgs: [
        #     pkgs.gamescope
        #     pkgs.gamemode
        #   ];
        # })
        master.nexusmods-app-unfree
        protonup-qt
        # xboxdrv # original xbox/xbox360 userspace driver
      ];
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      mangohud # add 'mangohud %command%' to steam launch option
      # playonlinux
      steam-run  # FHS env
    ];

    # nix-gaming cache
    nix.settings = {
      substituters = ["https://nix-gaming.cachix.org"];
      trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
    };

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      # ptricks flatpak works, this gives errors when starting, also takes a while to build
      # protontricks.enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play      
    };

    programs.gamescope.enable = true;

    # To make sure Steam starts a game with GameMode, right click the game, 
    # select Properties..., then Launch Options and enter:
    # gamemoderun %command%
    programs.gamemode = {
      enable = true;
      settings.custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };

    services.flatpak = {
      packages = [
        "com.github.Matoking.protontricks"
      ];
    };

  };
}
