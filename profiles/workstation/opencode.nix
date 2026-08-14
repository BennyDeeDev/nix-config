{ repoRoot, ... }:

{
  homeManager = { pkgs, ... }: {
    programs.opencode = {
      enable = true;
      package = pkgs.opencode;
      settings = builtins.fromJSON (
        builtins.readFile "${repoRoot}/files/opencode/opencode.json"
      );
      tui = builtins.fromJSON (
        builtins.readFile "${repoRoot}/files/opencode/tui.json"
      );
      context = repoRoot + "/files/opencode/AGENTS.md";
      agents = repoRoot + "/files/opencode/agents";
    };

    home.sessionVariables.OPENCODE_MODEL = "openai/gpt-5.6-luna#xhigh";
  };
}
