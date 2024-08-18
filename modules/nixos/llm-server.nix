{
  config,
  inputs,
  lib,
  pkgs,
  ... }:
with lib; let
  cfg = config.my.llm-server;
in {
  options.my.llm-server = {
    enable = mkEnableOption "enable llm-server";

  };

  config = mkIf cfg.enable {

    services.ollama = {
      enable = true;
      acceleration = false;  # takes a long time to compile
      package = pkgs.unstable.ollama;
    };

    # https://github.com/NixOS/nixpkgs/issues/331056
    # currently build failing
    # services.open-webui = {
    #   enable = true;
    #   package = pkgs.unstable.open-webui;
    # };

  };
}
