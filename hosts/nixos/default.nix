# configuration for WSL 
{
  config,
  inputs,
  lib,
  pkgs,
  options,
  home-manager,
  ... 
}:
let
  userName = "nixos";
  device-name = "nixos";
in
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    # inputs.vscode-server.nixosModules.default
  ];

  # makes the rebuild work without specifying the cert file
  security.pki.certificateFiles = [ /mnt/c/ProgramData/tls-ca-bundle.pem ]; # path to your corporate CA bundle
  
  # set environment variables
  environment.variables = {
    # set the bundle path for python/requests
    REQUESTS_CA_BUNDLE = "/mnt/c/ProgramData/tls-ca-bundle.pem";  # without qoutes the file is copied to the nix store
  };

  nixpkgs.hostPlatform.system = "x86_64-linux";
  wsl.enable = true;
  wsl.defaultUser = "nixos";

  my.user.userName = userName;

  home-manager.users."${userName}" = import ../../home-manager/home.nix;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    unstable.brave
    bun
    unstable.mamba-cpp
    podman-compose
    # python3
    # pipenv
    unstable.vscode-fhs
    unstable.zellij
    wslu
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Run unpatched dynamic binaries on NixOS, e.g. vscode server
  programs.nix-ld.enable = true;

  # List services that you want to enable:
  services.tailscale.enable = false;

  # Enable the OpenSSH daemon.
  # services.openssh = {
  #   enable = true;
  #   # require public key authentication for better security
  #   settings.PasswordAuthentication = false;
  #   settings.KbdInteractiveAuthentication = false;
  #   #settings.PermitRootLogin = "yes";
  # };

  # # enable VScode server support - 20250616 couldn't get working so went with nix-ld
  # # https://nixos.wiki/wiki/Visual_Studio_Code, 1st time setup is needed on client and host
  # services.vscode-server.enable = true;
  # services.vscode-server.enableFHS = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}