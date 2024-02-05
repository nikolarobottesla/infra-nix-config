{userName, ...}: { config, home-manager, lib, pkgs, ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.${userName} = { pkgs, ... }: {
    home.packages = with pkgs; [
      podman-compose
    ];
    # programs.bash.enable = true;

    programs.git = {
      enable = true;
      userName  = "nikolarobottesla";
      userEmail = "13294739+nikolarobottesla@users.noreply.github.com";
    };

  };
}