# sources: https://github.com/GGG-KILLER/nixos-configs/blob/6c3d1a71890c246e42f268767a5a4d9d8c8a0263/hosts/sora/users/ggg/vscode.nix#L67 - powershell stuff

{
  lib,
  config,
  pkgs,
  ... }: let
  inherit (lib) getExe;
in {
  imports = [
    ./firefox.nix
  ];

  # something for qemu
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
  programs.vscode = {
    enable = true;
    profiles.default.enableUpdateCheck = false;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      # danielsanmedium.dscodegpt
      ms-python.python # pylance and debugger
      # ms-vscode.remote-explorer # not available
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      ms-vscode.powershell
      # ms-vscode.remote-server # not available
      yzhang.markdown-all-in-one
    ];
    # package = pkgs.vscode.fhs;  # if enabled, server needs special treatment
    profiles.default.userSettings = {
      # "CodeGPT.apiKey" = "Ollama";
      "powershell.powerShellAdditionalExePaths" = {
        "PowerShell Core 7 (x64)" = getExe pkgs.powershell;
      };
      "powershell.promptToUpdatePowerShell" = false;
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;
      "update.mode" = "none";

      "[nix]"."editor.tabSize" = 2;
      "diffEditor.hideUnchangedRegions.enabled" = true;
      "git.autofetch" = true;
      "git.enableCommitSigning" = true;
      # "remote.SSH.useLocalServer" = false;  had this set but don't know why
    };
  };

  # https://github.com/iynaix/dotfiles/blob/96e7056e9ab284731aef4fa278648aed8ecab346/nixos/plasma.nix#L20
  # set dark theme, adapted from plasma-manager
  xdg.configFile."autostart/plasma-dark-mode.desktop".text =
    let
      plasmaDarkMode = pkgs.writeShellScriptBin "plasma-dark-mode" ''
        plasma-apply-lookandfeel -a org.kde.breezedark.desktop
        plasma-apply-desktoptheme breeze-dark
      '';
    in
    ''
      [Desktop Entry]
      Type=Application
      Name=Plasma Dark Mode
      Exec=${lib.getExe plasmaDarkMode}
      X-KDE-autostart-condition=ksmserver
    '';
}
