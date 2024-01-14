{
  description = "build nix";
  inputs = {
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixOS/nixos-hardware";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, home-manager, nixos-hardware, nixpkgs, vscode-server}: rec {
    nixosConfigurations = {
      rpi4Image = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ./rpi-config.nix
          home-manager.nixosModules.home-manager
          nixos-hardware.nixosModules.raspberry-pi-4
          vscode-server.nixosModules.default
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
      rpi4 = nixpkgs.lib.nixosSystem {
        modules = [
          /etc/nixos/hardware-config.nix  # run nixos-generate-config 1st
          ./rpi-config.nix
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