{
  homeManager = { pkgs, ... }: {
    programs.opencode = {
      enable = true;
      package = pkgs.opencode;
      settings = builtins.fromJSON (builtins.readFile ../../files/opencode/opencode.json);
      tui = builtins.fromJSON (builtins.readFile ../../files/opencode/tui.json);
      context = ../../files/opencode/AGENTS.md;
      agents = ../../files/opencode/agents;
    };

    programs.zsh.shellAliases.o = "oc-exa";
    programs.zsh.shellAliases.oc-exa = "OPENCODE_ENABLE_EXA=1 OPENCODE_WEBSEARCH_PROVIDER=exa opencode";
    programs.zsh.shellAliases.oc-parallel = "OPENCODE_ENABLE_PARALLEL=1 OPENCODE_WEBSEARCH_PROVIDER=parallel opencode";
  };
}
