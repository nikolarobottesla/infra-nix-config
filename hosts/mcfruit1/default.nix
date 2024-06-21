{
  config,
  inputs,
  pkgs,
  ...
}: let
  userName = "a1rc7zz";
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
  home-manager.users."${userName}" = import ../../home-manager/home.nix;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    awscli
    aldente # macOS tool to limit maximum charging %
    curl
    # darwin.xcode
    direnv
    git
    htop
    jq
    vscode
    # xcodes
    # kate
    # rclone
  ];

  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    # enableRosetta = true;

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
  };
  homebrew.enable = true; # enables in nix-darwin, doeasn't install
  homebrew.onActivation.cleanup = "zap";  # uninstall app
  homebrew.onActivation.upgrade = true; # upgrade homebrew on system activation
  homebrew.brews = [
    "podman"
    "podman-compose"
  ];
  homebrew.casks = [
    # "avidemux"  # developer cannot be verified
    "clementine"
    "google-chrome"
    "nextcloud"
    "rectangle"
    "obsidian"
    # "podman-desktop"
    "qcad"
    "freecad"
    # "lm-studio"  # requires Arm 64
    # {  not working, keep getting 'try again' popup
    #   name = "wacom-tablet";
    #   greedy = true;
    # }
  ];

  system.defaults.dock.autohide = true;
  system.defaults.dock.minimize-to-application = true;
  system.defaults.dock.mru-spaces = false;
  # system.defaults.dock.orientation = "left";
  system.defaults.dock.showhidden = true;
  system.defaults.dock.persistent-apps = [
    "/Applications/Microsoft Outlook.app"
    "/Applications/Microsoft Teams.app"
    "/Applications/Microsoft OneNote.app"
    "/Applications/OneDrive.app"
    "/Applications/Microsoft Word.app"
    "/Applications/Microsoft Excel.app"
    "/Applications/Microsoft PowerPoint.app"
    "/Applications/Nix Apps/Visual Studio Code.app"
    "/System/Applications/Utilities/Terminal.app"
    "/Applications/Firefox.app"
    "/Applications/Safari.app"
    "/Applications/Self Service.app"
    "/System/Applications/System Settings.app"
  ];

  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;

  services.tailscale.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
  nix.gc.automatic = true;
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.hostPlatform = "x86_64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.bash.enableCompletion = true;
  programs.zsh.enableBashCompletion = true;
  programs.zsh.enableFzfCompletion = true;
  programs.zsh.enableFzfGit = true;
  programs.zsh.enableFzfHistory = true;
  programs.zsh.enableSyntaxHighlighting = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
