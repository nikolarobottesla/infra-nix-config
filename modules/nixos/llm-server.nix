{
  config,
  inputs,
  lib,
  pkgs,
  ... }:
with lib; let
  cfg = config.my.llm-server;
in {
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/open-webui.nix"
  ];
  
  options.my.llm-server = {
    enable = mkEnableOption "enable llm-server";

  };

  config = mkIf cfg.enable {

    services.ollama = {
      enable = true;
      acceleration = false;  # takes a long time to compile
      package = pkgs.unstable.ollama;
    };
  
    services.open-webui = {
      enable = true;
      package = pkgs.unstable.open-webui;
    };

  };
}
