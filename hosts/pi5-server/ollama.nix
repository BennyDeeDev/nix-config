{
  nixos =
    { pkgs, ... }:
    {
      services.ollama = {
        enable = true;
        package = pkgs.ollama-cpu;
        host = "127.0.0.1";
        loadModels = [ "qwen3.5:2b" ];
        environmentVariables = {
          OLLAMA_MAX_LOADED_MODELS = "1";
          OLLAMA_NUM_PARALLEL = "1";
        };
      };
    };
}
