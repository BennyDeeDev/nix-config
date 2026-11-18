let
  ollamaThinkingOverlay = import ../../overlays/llama-index-ollama-thinking.nix;
in
{
  nixos =
    { pkgs, ... }:
    {
      services.paperless = {
        enable = true;
        package = pkgs.paperless-ngx.override {
          extraPythonPackageOverrides = ollamaThinkingOverlay;
        };
        address = "127.0.0.1";
        domain = "docs.benjaminderksen.com";
        settings = {
          PAPERLESS_DBENGINE = "sqlite";
          PAPERLESS_OCR_LANGUAGE = "deu+eng";
          PAPERLESS_TASK_WORKERS = 1;
          PAPERLESS_THREADS_PER_WORKER = 2;
          PAPERLESS_AI_ENABLED = true;
          PAPERLESS_AI_LLM_BACKEND = "ollama";
          PAPERLESS_AI_LLM_ENDPOINT = "http://127.0.0.1:11434";
          PAPERLESS_AI_LLM_MODEL = "qwen3.5:2b";
          PAPERLESS_AI_LLM_OUTPUT_LANGUAGE = "de";
          PAPERLESS_AI_LLM_CONTEXT_SIZE = 2048;
          PAPERLESS_AI_LLM_REQUEST_TIMEOUT = 300;
          PAPERLESS_AI_LLM_EXTRA_PARAMS.temperature = 0;
        };
        tesseractLanguages = null;
      };

      my.restic.paperless = {
        repository = "/mnt/nas/restic/paperless-restic";
        paths = [ "/var/lib/paperless" ];
        services = [
          "paperless-consumer.service"
          "paperless-scheduler.service"
          "paperless-task-queue.service"
          "paperless-web.service"
        ];
        mountPoint = "/mnt/nas/restic";
      };
    };
}
