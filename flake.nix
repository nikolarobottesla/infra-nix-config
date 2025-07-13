{
  description = "nikolarobottesla NixOS flake";
  inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Declarative tap management
    # homebrew-core.url = "github:homebrew/homebrew-core";
    # homebrew-core.flake = false;
    # homebrew-cask.url = "github:homebrew/homebrew-cask";
    # homebrew-cask.flake = false;
    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.2";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixos-hardware.url = "github:nikolarobottesla/nixos-hardware/master";
    nixos-wsl.url = github:nix-community/NixOS-WSL;
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # nix-darwin.url = "github:LnL7/nix-darwin";
    # nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nix-gaming.url = "github:fufexan/nix-gaming";
    # nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    disko,
    home-manager,
    # homebrew-core,
    # homebrew-cask,
    lanzaboote,
    nixos-hardware,
    nixos-wsl,
    nixpkgs,
    nixpkgs-unstable,
    # nix-darwin,
    nix-flatpak,
    nix-gaming,
    # nix-homebrew,
    sops-nix,
    vscode-server,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      # "aarch64-darwin"
      # "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
    defaultModules = [
      home-manager.nixosModules.default
      nix-flatpak.nixosModules.nix-flatpak
      sops-nix.nixosModules.sops
      ./modules/nixos
      ./modules/home-manager
    ];
  in rec {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    # packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    # homeManagerModules = import ./modules/home-manager;

    # darwinConfigurations = let
    #   specialArgs = {inherit inputs outputs defaultModules;};
    # in {
    #   "3MC02CM4GNMD6N" = nix-darwin.lib.darwinSystem {
    #     inherit specialArgs;
    #     modules = [
    #       home-manager.darwinModules.home-manager
    #       ./hosts/mcfruit1
    #     ];
    #   };
    #   "cinnamon-ice" = nix-darwin.lib.darwinSystem {
    #     inherit specialArgs;
    #     modules = [
    #       home-manager.darwinModules.home-manager
    #       ./hosts/cinnamon-ice
    #     ];
    #   };
    # };
    nixosConfigurations = let
      # defaultModules = [
      #   ./modules/nixos
      #   home-manager.nixosModules.default
      #   sops-nix.nixosModules.sops
      # ];
      specialArgs = {inherit inputs outputs defaultModules;};
    in {
      "15TH-TURTLE" = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules =
          defaultModules
          ++ [
            ./hosts/15TH-TURTLE
          ];
      };
      # coconuts: set user password before applying
      coconut-2 = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules =
          defaultModules
          ++ [
            (import ./hosts/coconut {hostName = "coconut-2";})
            {
              time.timeZone = "America/Chicago";
              services.tailscale.useRoutingFeatures = "client";
            }
          ];
      };
      coconut-3 = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules =
          defaultModules
          ++ [
            (import ./hosts/coconut {hostName = "coconut-3";})
            {
              time.timeZone = "America/Los_Angeles";
              services.tailscale.useRoutingFeatures = "both";
            }
          ];
      };
      dark-desk = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules =
          defaultModules
          ++ [
            ./hosts/dark-desk
          ];
      };
      # wsl
      nixos = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules =
          defaultModules
          ++ [
            ./hosts/nixos
          ];
      };
      oakImage = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules =
          defaultModules
          ++ [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            (import ./modules/remote-install {hostName = "oak";})
            disko.nixosModules.disko
            {
              nixpkgs.hostPlatform.system = "x86_64-linux";
              nixpkgs.buildPlatform.system = "x86_64-linux";
            }
          ];
      };
      oak-1 = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules =
          defaultModules
          ++ [
            ./hosts/oak-1
          ];
      };
      oak-2 = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules =
          defaultModules
          ++ [
            ./hosts/oak-2
          ];
      };
      rpi4Image = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules =
          defaultModules
          ++ [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            nixos-hardware.nixosModules.raspberry-pi-4
            {
              nixpkgs.config.allowUnsupportedSystem = true;
              nixpkgs.hostPlatform.system = "aarch64-linux";
              nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.
              # ... extra configs

              my.pi4.enable = true;
              my.remote-install = {
                enable = true;
                hostName = "coconut-3"; # change before build
              };

              nixpkgs.overlays = [
                (final: super: {
                  makeModulesClosure = x:
                    super.makeModulesClosure (x // {allowMissing = true;});
                })
              ];
            }
          ];
      };
      shialt = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules =
          defaultModules
          ++ [
            ./hosts/shialt
          ];
      };
    };
    image.rpi4 = nixosConfigurations.rpi4Image.config.system.build.sdImage;
    image.oak = nixosConfigurations.oakImage.config.system.build.isoImage;
  };
}
