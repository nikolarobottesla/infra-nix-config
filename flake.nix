{
  description = "Build pi4 image";
  inputs = {
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixOS/nixos-hardware";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };
  outputs = { self, home-manager, nixos-hardware, nixpkgs, vscode-server}: rec {
    nixosConfigurations.rpi4 = nixpkgs.lib.nixosSystem {
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
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
    };
    images.rpi4 = nixosConfigurations.rpi4.config.system.build.sdImage;
  };
}