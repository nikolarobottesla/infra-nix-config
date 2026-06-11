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

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Force home-manager's nix module to be enabled (overriding the False propagated
  # from nix-darwin's nix.enable=false) so that the activation script uses
  # the nix package (from nix-darwin's nix.package) for activation tools.
  # This fixes the "missing operand" and "nix-build: command not found" errors
  # when using determinate nix on macOS.
  nix.enable = lib.mkForce true;

  # Enable home-manager
  programs.home-manager.enable = true;

  # configure git
  xdg.configFile."git/config".text = lib.generators.toGitINI {
    user.name = "nikolarobottesla";
    signing.signByDefault = true;
    credential.helper = "!${pkgs.gh}/bin/gh auth git-credential";
    commit.gpgSign = true;
  };

  # configure an npm global prefix in home directory and add to path
  home.file.".npmrc".text =
    ''
      prefix=~/.npm-global
    '';
  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin/"
  ];

  # configure a .condarc file in .conda folder
  home.file.".conda/.condarc".text =
    ''
      channels:
        - conda-forge
      mirrored_channels:
        conda-forge:
          - https://conda.anaconda.org/conda-forge
          - https://prefix.dev/conda-forge
      envs_dirs:
        - ~/.conda/envs
      pkgs_dirs:
        - ~/.conda/pkgs
    '';

  programs.zsh = {
    enable = true;
    # Migrate existing ~/.zshrc content here so home-manager can manage ~/.zshrc.
    # This also causes home-manager to generate ~/.zshenv, which sources
    # hm-session-vars.sh and makes home.sessionPath work.
    initContent = ''
      export PATH="''${HOMEBREW_PREFIX}/opt/openssl/bin:$PATH"
      eval "$(/opt/homebrew/bin/brew shellenv)"

      # >>> conda initialize >>>
      # !! Contents within this block are managed by 'conda init' !!
      __conda_setup="$('${config.home.homeDirectory}/.conda/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
      if [ $? -eq 0 ]; then
          eval "$__conda_setup"
      else
          if [ -f "${config.home.homeDirectory}/.conda/etc/profile.d/conda.sh" ]; then
              . "${config.home.homeDirectory}/.conda/etc/profile.d/conda.sh"
          else
              export PATH="${config.home.homeDirectory}/.conda/bin:$PATH"
          fi
      fi
      unset __conda_setup
      # <<< conda initialize <<<

      # Created by `pipx` on 2026-03-23 19:38:32
      export PATH="$PATH:${config.home.homeDirectory}/.local/bin"
    '';
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}