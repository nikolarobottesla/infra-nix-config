{
  description = "build nix";
  inputs = {
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nikolarobottesla/nixos-hardware/nikolarobottesla-patch-1";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, agenix, disko, home-manager, nixos-hardware, nixpkgs, vscode-server}: rec {
    nixosConfigurations = {
      "15TH-TURTLE" = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          nixos-hardware.nixosModules.hp-elitebook-830-g6
          ./hosts/15TH-TURTLE
          # ./default.nix
          agenix.nixosModules.default
          {
            environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
          }
        ];
      };
      "oak-1" = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./modules/root-ssh-auth
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          vscode-server.nixosModules.default
          ./hosts/oak-1
          {
            nixpkgs.hostPlatform.system = "x86_64-linux";
            nixpkgs.buildPlatform.system = "x86_64-linux";
            
            # nixpkgs.overlays = [
            #   (final: super: {
            #     makeModulesClosure = x:
            #       super.makeModulesClosure (x // { allowMissing = true; });
            #   })
            # ];
          }
        ];
      };
      rpi4Image = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ./pi-config.nix
          home-manager.nixosModules.home-manager
          nixos-hardware.nixosModules.raspberry-pi-4
          vscode-server.nixosModules.default
          ./modules/root-ssh-auth
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
      rpi4 = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/coconut-2.nix
          ./pi-config.nix
          home-manager.nixosModules.home-manager
          nixos-hardware.nixosModules.raspberry-pi-4
          vscode-server.nixosModules.default
        ];
      };
    };
    image.rpi4 = nixosConfigurations.rpi4Image.config.system.build.sdImage;
    build.rpi4 = nixosConfigurations.rpi4.config.system.build.toplevel;
    image.oak-1 = nixosConfigurations.oak-1.config.system.build.isoImage;

  };
}