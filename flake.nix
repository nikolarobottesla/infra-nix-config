{
  description = "build nix";
  inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nikolarobottesla/nixos-hardware/nikolarobottesla-patch-1";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, disko, home-manager, nixos-hardware, nixpkgs, vscode-server}: rec {
    nixosConfigurations = {
      "15TH-TURTLE" = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          nixos-hardware.nixosModules.hp-elitebook-830-g6
          ./workstation.nix
        ];
      };
      rpi4Image = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ./pi-config.nix
          home-manager.nixosModules.home-manager
          nixos-hardware.nixosModules.raspberry-pi-4
          vscode-server.nixosModules.default
          {
            nixpkgs.config.allowUnsupportedSystem = true;
            nixpkgs.hostPlatform.system = "aarch64-linux";
            nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.
            # ... extra configs

            users.users.root.openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOC+HHp89/1OdTo5dEiBxE3knDSCs9WDg6qIXPitBC83 15TH-TURTLE"
            ];

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
          ./devices/coconut-2.nix
          ./pi-config.nix
          home-manager.nixosModules.home-manager
          nixos-hardware.nixosModules.raspberry-pi-4
          vscode-server.nixosModules.default
        ];
      };
    };
    images.rpi4 = nixosConfigurations.rpi4Image.config.system.build.sdImage;
    builds.rpi4 = nixosConfigurations.rpi4.config.system.build.toplevel;
    
  };
}