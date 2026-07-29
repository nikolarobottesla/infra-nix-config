{
  config,
  inputs,
  lib,
  outputs,
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
  ];

  nixpkgs.overlays = [
    outputs.overlays.unstable-packages
  ];

  # Let Determinate Nix handle Nix configuration
  nix.enable = false;

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
    (import ../../home-manager/firefox.nix)
    {
      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = "25.11";
    }
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    awscli
    bun
    # curl # this curl doesn't seem to use system certs
    # darwin.xcode
    gh
    devenv
    direnv
    ffmpeg # req for hermes
    ghostty-bin # macos version of ghostty terminal emulator
    # git # git is provided by developer tools, nix version doesn't use system certs by default 
    gnupg # if vscode can't find gpg, restart it
    htop
    jq
    nodejs_24
    powershell # pwsh
    ripgrep # req for hermes
    tailscale
    uv # req for hermes
    # xcodes
  ];

  environment.variables.UV_SYSTEM_CERTS  = "true";
  environment.variables.NODE_EXTRA_CA_CERTS = "${userHome}/tls-ca-bundle.pem"; # get from IT

  # nix-homebrew = {
  #   # Install Homebrew under the default prefix
  #   enable = true;

  #   # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
  #   # enableRosetta = true;  # this may have caused homebrew issues
 
  #   # User owning the Homebrew prefix
  #   user = userName;

  #   # Optional: Declarative tap management
  #   taps = {
  #     "homebrew/homebrew-core" = inputs.homebrew-core;
  #     "homebrew/homebrew-cask" = inputs.homebrew-cask;
  #   };

  #   # Optional: Enable fully-declarative tap management
  #   #
  #   # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
  #   # mutableTaps = false;
  #   # Automatically migrate existing Homebrew installations
  #   autoMigrate = true;
  # };
  homebrew.enable = true; # enables in nix-darwin, doesn't install
  homebrew.onActivation.cleanup = "zap";  # uninstall app
  homebrew.onActivation.upgrade = true; # upgrade homebrew on system activation
  homebrew.brews = [
    "podman"
    "podman-compose"
    "rtk" # rtk gain
  ];
  homebrew.casks = [
    # "aldente" # macOS has user config limit built in now
    # "avidemux"  # developer cannot be verified
    # "clementine"
    # "freecad"
    "google-chrome"
    # "kicad" # installed an out of date version even thougn the current version is listed on homebrew site, maybe it was because the flake wasn't updated but the declarative tap managemnt is commented out, waht is the default?
    "krita"
    # "lm-studio"  # requires Arm 64
    "nextcloud"
    "obsidian"
    "podman-desktop"
    # "qcad"
    "rectangle"
    "stats"  # system monitor
    "visual-studio-code"
    # {  not working, keep getting 'try again' popup
    #   name = "wacom-tablet";
    #   greedy = true;
    # }
  ];

  system.primaryUser = userName;
  system.defaults.dock.autohide = true;
  system.defaults.dock.minimize-to-application = true;
  system.defaults.dock.mru-spaces = false;
  # system.defaults.dock.orientation = "left";
  system.defaults.dock.persistent-apps = [
    "/Applications/Microsoft Outlook.app"
    "/Applications/Microsoft Teams.app"
    "/Applications/Microsoft OneNote.app"
    "/Applications/OneDrive.app"
    "/Applications/Microsoft Word.app"
    "/Applications/Microsoft Excel.app"
    "/Applications/Microsoft PowerPoint.app"
    "/Applications/Visual Studio Code.app"
    # "/System/Applications/Utilities/Terminal.app"
    "/Applications/Nix Apps/Ghostty.app"
    "/Users/${userName}/Applications/Home Manager Apps/Firefox.app"
    "/Applications/Safari.app"
    "/Applications/Self Service.app"
    "/System/Applications/System Settings.app"
  ];
  system.defaults.dock.showhidden = true;
  system.defaults.dock.tilesize = 50;

  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;  # natural scrolling off
  system.defaults.NSGlobalDomain."com.apple.trackpad.trackpadCornerClickBehavior" = 1;  # enable right click with trackpad
  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;

  services.tailscale.enable = true;
  services.tailscale.package = pkgs.unstable.tailscale;

  # Auto upgrade nix package and the daemon service.
  nix.package = pkgs.nix;
  # nix.gc.automatic = true;  # can't set while using determinate
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  programs.bash.completion.enable = true;
  # didn't seem to work
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.zsh.enableBashCompletion = true;
  programs.zsh.enableFzfCompletion = true;
  programs.zsh.enableFzfGit = true;
  programs.zsh.enableFzfHistory = true;
  programs.zsh.enableSyntaxHighlighting = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
