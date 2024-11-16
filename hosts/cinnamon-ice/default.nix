{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  userName = "katharine";
  userHome = "/Users/${userName}";
  # specialArgs =
  #   inputs
  #   // {
  #     inherit userName userHome ;
  #   };
in {
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ../../modules/home-manager
  ];

  # this might be needed to get other stuff to work
  # didn't notice the 'persistant-apps' working until after I added this.
  # the 3rd element must match the username
  users.users.${userName} = {
      name = userName;
      home = userHome;
  };

  # home-manager.extraSpecialArgs = specialArgs;
  home-manager.users."${userName}" = lib.mkMerge [
    (import ../../home-manager/home.nix)
    {
      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = "24.05";
    }
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # awscli
    aldente # macOS tool to limit maximum charging %
    curl
    # darwin.xcode
    # direnv
    git
    htop
    # jq
    vscode
    # xcodes
    # kate
    # rclone
  ];

  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;

    # User owning the Homebrew prefix
    user = userName;

    # Optional: Declarative tap management
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };

    # Optional: Enable fully-declarative tap management
    #
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    # mutableTaps = false;
    
    # Automatically migrate existing Homebrew installations
    autoMigrate = true;
  };
  homebrew.enable = true; # enables in nix-darwin, doeasn't install
  homebrew.onActivation.cleanup = "zap";  # uninstall app
  homebrew.onActivation.upgrade = true; # upgrade homebrew on system activation
  # homebrew.brews = [
  #   "podman"
  #   "podman-compose"
  # ];
  homebrew.casks = [
    # "avidemux"  # developer cannot be verified
    # "clementine"
    "firefox"
    "google-chrome"
    "libreoffice"
    # "nextcloud"
    # "rectangle"
    # "obsidian"
    # "podman-desktop"
    # "qcad"
    # "freecad"
    # "lm-studio"  # requires Arm 64
    # {  not working, keep getting 'try again' popup
    #   name = "wacom-tablet";
    #   greedy = true;
    # }
  ];

  system.defaults.dock.autohide = false;
  system.defaults.dock.minimize-to-application = true;
  system.defaults.dock.mru-spaces = false;
  # system.defaults.dock.orientation = "left";
  system.defaults.dock.showhidden = true;
  system.defaults.dock.persistent-apps = [
    # "/Applications/OneDrive.app"
    # "/Applications/Nix Apps/Firefox.app"
    # "/System/Applications/Utilities/Terminal.app"
    "/Applications/Firefox.app"
    "/Applications/Google Chrome.app"
    "/Applications/Safari.app"
    "/Applications/LibreOffice.app"
    "/System/Applications/System Settings.app"
  ];

  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
  
  system.defaults.NSGlobalDomain."com.apple.trackpad.trackpadCornerClickBehavior" = 1;  # enable right click with trackpad
  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;
  
  services.tailscale.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
  nix.gc.automatic = true;
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}