{
  description = "nikolarobottesla NixOS flake";
  inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nikolarobottesla/nixos-hardware/nikolarobottesla-patch-1";
    nixos-wsl.url = github:nix-community/NixOS-WSL;
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.1.0";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = 
    { self
    , disko
    , home-manager
    , nixos-hardware
    , nixos-wsl
    , nixpkgs
    , nix-flatpak
    , sops-nix
    , vscode-server
    , ...
    }@inputs:
    let
      inherit (self) outputs;
      # forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ];
    in
    rec {

      nixosConfigurations = 
        let
          defaultModules = [
            ./modules/nixos
            home-manager.nixosModules.default
            sops-nix.nixosModules.sops
          ];
          specialArgs = { inherit inputs outputs; };
        in 
        {
        "15TH-TURTLE" = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = defaultModules ++ [
            ./hosts/15TH-TURTLE
          ];
        };
        oakImage = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = defaultModules ++ [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            (import ./modules/remote-install { hostName = "oak"; })
            disko.nixosModules.disko
            {
              nixpkgs.hostPlatform.system = "x86_64-linux";
              nixpkgs.buildPlatform.system = "x86_64-linux";
            }
          ];
        };
        oak-1 = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = defaultModules ++ [
            ./hosts/oak-1
          ];
        };
        rpi4Image = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = defaultModules ++ [
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
                hostName = "coconut-3";  # change before build
              };

              nixpkgs.overlays = [
                (final: super: {
                  makeModulesClosure = x:
                    super.makeModulesClosure (x // { allowMissing = true; });
                })
              ];
            }
          ];
        };
        # coconuts: set user password before applying
        coconut-2 = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = defaultModules ++ [
            (import ./hosts/coconut { hostName = "coconut-2"; })
            {
              time.timeZone = "America/Chicago";
              services.tailscale.useRoutingFeatures = "client";
            }
          ];
        };
        coconut-3 = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = defaultModules ++ [
            (import ./hosts/coconut { hostName = "coconut-3"; })
            {
              time.timeZone = "America/Los_Angeles";
              services.tailscale.useRoutingFeatures = "both";
            }
          ];
        };
        # wsl
        nixos = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = defaultModules ++ [
            ./hosts/nixos
          ];
        };
      };
      image.rpi4 = nixosConfigurations.rpi4Image.config.system.build.sdImage;
      image.oak = nixosConfigurations.oakImage.config.system.build.isoImage;

    };
}