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
        (extension "privacy-badger" "jid1-MnnxcxisBPnSXQ@jetpack")
        (extension "ublock-origin" "uBlock0@raymondhill.net")
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
    Preferences = {
      "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
      "browser.newtabpage.activity-stream.showSearch" = true;
      "browser.newtabpage.activity-stream.feeds.topsites" = true;
      "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
      "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      "browser.newtabpage.activity-stream.feeds.snippets" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      "browser.newtabpage.activity-stream.showSponsored" = false;
      "browser.startup.page" = "previous-session";
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
