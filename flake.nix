{
  description = "build nix";
  inputs = {
    # agenix.url = "github:ryantm/agenix";
    # agenix.inputs.nixpkgs.follows = "nixpkgs";
    # agenix.inputs.darwin.follows = "";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nikolarobottesla/nixos-hardware/nikolarobottesla-patch-1";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, disko, home-manager, nixos-hardware, nixpkgs, sops-nix, vscode-server}: rec {
    nixosConfigurations = {
      "15TH-TURTLE" = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          nixos-hardware.nixosModules.hp-elitebook-830-g6
          sops-nix.nixosModules.sops
          ./hosts/15TH-TURTLE
          # ./default.nix
          # agenix.nixosModules.default
          # {
          #   environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
          # }
        ];
      };
      oakImage = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          (import ./modules/remote-install { hostName = "oak"; })
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          {
            nixpkgs.hostPlatform.system = "x86_64-linux";
            nixpkgs.buildPlatform.system = "x86_64-linux";
          }
        ];
      };
      oak-1 = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          vscode-server.nixosModules.default
          sops-nix.nixosModules.sops
          ./hosts/oak-1
        ];
      };
      rpi4Image = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ./hosts/coconut-2/default.nix
          home-manager.nixosModules.home-manager
          nixos-hardware.nixosModules.raspberry-pi-4
          vscode-server.nixosModules.default
          ./modules/remote-install { hostName = "nix-pi"; }
          {
            nixpkgs.config.allowUnsupportedSystem = true;
            nixpkgs.hostPlatform.system = "aarch64-linux";
            nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.
            # ... extra configs

            nixpkgs.overlays = [
              (final: super: {
                makeModulesClosure = x:
                  super.makeModulesClosure (x // { allowMissing = true; });
              })
            ];
          }
        ];
      };
      # set user password before applying
      coconut-2 = nixpkgs.lib.nixosSystem {
        modules = [
          home-manager.nixosModules.home-manager
          nixos-hardware.nixosModules.raspberry-pi-4
          sops-nix.nixosModules.sops
          vscode-server.nixosModules.default
          ./hosts/coconut-2
        ];
      };
    };
    image.rpi4 = nixosConfigurations.rpi4Image.config.system.build.sdImage;
    image.oak = nixosConfigurations.oakImage.config.system.build.isoImage;

  };
}