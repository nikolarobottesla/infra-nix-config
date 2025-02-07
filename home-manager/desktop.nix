# sources: https://github.com/GGG-KILLER/nixos-configs/blob/6c3d1a71890c246e42f268767a5a4d9d8c8a0263/hosts/sora/users/ggg/vscode.nix#L67 - powershell stuff

{
  lib,
  config,
  pkgs,
  ... }: let
  inherit (lib) getExe;
in {
  # something for qemu
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
  programs.firefox.enable = true;
  # https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/17
  programs.firefox.policies = {
    ExtensionSettings = with builtins;
      let extension = shortId: uuid: {
        name = uuid;
        value = {
          install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
          installation_mode = "normal_installed";
        };
      };
      in listToAttrs [
        (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
        (extension "fakespot-fake-reviews-amazon" "{44df5123-f715-9146-bfaa-c6e8d4461d44}")
        # (extension "Ninja Cookie" "debug@ninja-cookie.com")
        (extension "I still don't care about cookies" "idcac-pub@guus.ninja")
        (extension "privacy-badger" "jid1-MnnxcxisBPnSXQ@jetpack")
        (extension "ublock-origin" "uBlock0@raymondhill.net")
        (extension "UltraWideo" "{2339288d-f701-45d0-a57f-a847e9adc6cc}")
        # (extension "tree-style-tab" "treestyletab@piro.sakura.ne.jp")
        # (extension "tabliss" "extension@tabliss.io")
        # (extension "umatrix" "uMatrix@raymondhill.net")
        # (extension "libredirect" "7esoorv3@alefvanoon.anonaddy.me")
        # (extension "clearurls" "{74145f27-f039-47ce-a470-a662b129930a}")
      ];
      # To add additional extensions, find it on addons.mozilla.org, find
      # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
      # install add on manually
      # get UUID from about:debugging#/runtime/this-firefox.
      # or about:support#addons

    /* ---- PREFERENCES ---- */
    # Set preferences shared by all profiles.
    # go to about:config to view preferences
    Preferences = {
      "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
      "browser.newtabpage.activity-stream.showSearch" = true;
      "browser.newtabpage.activity-stream.feeds.topsites" = true;
      "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
      "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      "browser.newtabpage.activity-stream.feeds.snippets" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      "browser.newtabpage.activity-stream.showSponsored" = false;
      "browser.shell.checkDefaultBrowser" = false;
      # Homepage settings
      # 0 = blank, 1 = home, 2 = last visited page, 3 = resume previous session
      "browser.startup.page" = 3;
      # "browser.startup.homepage" = "URL";  # browser.startup.page must be set to 1
      "extensions.formautofill.creditCards.enabled" = false;
      "extensions.pocket.enabled" = false;
      "signon.rememberSignons" = false;
      # "SearchEngines" = { "Default" = "DuckDuckGo";};  # need firefox ESR, also untested
      # "extensions.screenshots.disabled" = true;
      # add global preferences here...
    };
  };
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      danielsanmedium.dscodegpt
      ms-python.python # pylance and debugger
      # ms-vscode.remote-explorer # not available
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      ms-vscode.powershell
      # ms-vscode.remote-server # not available
      yzhang.markdown-all-in-one
    ];
    # package = pkgs.vscode.fhs;  # if enabled, server needs special treatment
    userSettings = {
      "CodeGPT.apiKey" = "Ollama";
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
