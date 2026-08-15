{ ... }:

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

    home.sessionVariables.OPENCODE_MODEL = "openai/gpt-5.6-luna#xhigh";
  };
}
