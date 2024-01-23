{hostName, ...}: { ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.hostName = "${ hostName }"; # Define your hostname.

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOC+HHp89/1OdTo5dEiBxE3knDSCs9WDg6qIXPitBC83 15TH-TURTLE"
  ];

  environment.systemPackages = with pkgs; [
    git
    htop
    iotop
    tmux
    tree
    wget
  ];
}