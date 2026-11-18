# Preserve explicit think=False so reasoning models return JSON instead of
# exhausting the context on thinking. Remove once the locked integration fixes
# https://github.com/run-llama/llama_index/issues/22467.
_final: prev: {
  llama-index-llms-ollama = prev.llama-index-llms-ollama.overridePythonAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace llama_index/llms/ollama/base.py \
        --replace-fail \
        'kwargs.pop("think", None) or self.thinking' \
        'kwargs.pop("think", self.thinking)'
    '';
  });
}
