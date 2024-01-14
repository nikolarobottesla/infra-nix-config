{user-name, ...}: { config, lib, pkgs, home-manager, ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.${user-name} = { pkgs, ... }: {
    # home.packages = [ pkgs.atool pkgs.httpie ];
    # programs.bash.enable = true;
    programs.git = {
      enable = true;
      userName  = "nikolarobottesla";
      userEmail = "13294739+nikolarobottesla@users.noreply.github.com";
    };

  };
}