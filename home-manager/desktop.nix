{
  lib,
  config,
  pkgs,
  ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };
  programs.firefox.enable = true;
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-python.python # pylance and debugger
      # ms-vscode.remote-explorer # not available
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      # ms-vscode.remote-server # not available
      yzhang.markdown-all-in-one
    ];
    # package = pkgs.vscode.fhs;  # if enabled, server needs special treatment
  };
}
