{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.opencode;
in {
  options.my.opencode = {
    enable = mkEnableOption "opencode pointed at the local ollama server";

    userName = mkOption {
      type = types.str;
      description = "user the opencode configuration is installed for";
      default = "nixos";
    };

    contextLength = mkOption {
      type = types.int;
      description = ''
        KV cache the ollama server allocates per request, and how much of it
        opencode is allowed to fill. Must match the OLLAMA_CONTEXT_LENGTH of
        services.ollama, otherwise opencode happily builds prompts the server
        cannot accept. Measured ~41KB per token for gemma4, so 65536 is about
        1.4GB of KV cache in q4_0 on top of 5.5GB of weights.
      '';
      default = 65536;
    };
  };

  config = mkIf cfg.enable {
    home-manager.users."${cfg.userName}".xdg.configFile."opencode/opencode.jsonc" = {
      text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        # gemma4 advertises tool support, so it can drive the agent loop
        model = "ollama/gemma4:latest";
        small_model = "ollama/gemma4:latest";

        provider.ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama (local)";
          options.baseURL = "http://localhost:11434/v1";
          models = {
            "gemma4:latest" = {
              name = "Gemma 4 7.5B (local)";
              limit = {
                context = cfg.contextLength;
                output = 8192;
              };
            };
            "llama3:8b" = {
              name = "Llama 3 8B (local, no tools)";
              limit = {
                context = 8192;
                output = 4096;
              };
            };
          };
        };
      };
      # a hand written opencode.jsonc (schema line only) predates this module and
      # would otherwise fail activation on every rebuild
      force = true;
    };
  };
}
