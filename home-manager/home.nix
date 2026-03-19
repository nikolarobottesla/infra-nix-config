# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  # no options allowed when using useGlobalPkgs
  # nixpkgs = {
  #   # You can add overlays here
  #   overlays = [
  #     # Add overlays your own flake exports (from overlays and pkgs dir):
  #   #   outputs.overlays.additions
  #   #   outputs.overlays.modifications
  #     # outputs.overlays.unstable-packages

  #     # You can also add overlays exported from other flakes:
  #     # neovim-nightly-overlay.overlays.default

  #     # Or define it inline, for example:
  #     # (final: prev: {
  #     #   hi = final.hello.overrideAttrs (oldAttrs: {
  #     #     patches = [ ./change-hello-to-hi.patch ];
  #     #   });
  #     # })
  #   ];
  #   # Configure your nixpkgs instance
  #   # config = {
  #   #   # Disable if you don't want unfree packages
  #   #   allowUnfree = true;
  #   # };
  # };

#   home = {
#     username = "your-username";
#     homeDirectory = "/home/your-username";
#   };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Force home-manager's nix module to be enabled (overriding the False propagated
  # from nix-darwin's nix.enable=false) so that the activation script uses
  # the nix package (from nix-darwin's nix.package) for activation tools.
  # This fixes the "missing operand" and "nix-build: command not found" errors
  # when using determinate nix on macOS.
  nix.enable = lib.mkForce true;

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    settings.user.name = "nikolarobottesla";
    settings.user.email = "13294739+nikolarobottesla@users.noreply.github.com";
    settings.credential.helper = "!${pkgs.gh}/bin/gh auth git-credential"; # used to override osxkeychain
  };

  # configure a .condarc file in .conda folder
  home.file.".conda/.condarc".text =
    ''
      channels:
        - conda-forge
      envs_dirs:
        - ~/.conda/envs
      pkgs_dirs:
        - ~/.conda/pkgs
    '';

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}