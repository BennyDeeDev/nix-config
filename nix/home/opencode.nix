{ pkgs, ... }:

{
  home.packages = [ pkgs.opencode ];

  home.sessionVariables = {
    OPENCODE_MODEL = "openai/gpt-5.6-luna#xhigh";
  };

  xdg.configFile."opencode/opencode.json".source = ../../opencode/opencode.json;
  xdg.configFile."opencode/tui.json".source = ../../opencode/tui.json;
  xdg.configFile."opencode/AGENTS.md".source = ../../opencode/AGENTS.md;
  xdg.configFile."opencode/agents".source = ../../opencode/agents;
}
