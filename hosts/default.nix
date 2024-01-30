{ ... }:

{
  # imports = [
  #   ./rclone
  # ];
  
  # Auto system update
  system.autoUpgrade = {
        enable = true;
        flake = "github:nikolarobottesla/infra-nix-config";
  };

  # Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}