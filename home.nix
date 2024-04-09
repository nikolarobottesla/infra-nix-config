# { userName, userHome, ... }:
{lib, ...}: {
  # home.username = userName;
  # home.homeDirectory = userHome;
  # home.packages = with pkgs; [
  #   podman-compose
  # ];
  # programs.bash.enable = true;

  programs.git = {
    enable = true;
    userName = "nikolarobottesla";
    userEmail = "13294739+nikolarobottesla@users.noreply.github.com";
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = lib.mkDefault "23.11";
}
