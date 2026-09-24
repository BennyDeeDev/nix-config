{
  homeManager =
    { lib, pkgs, ... }:
    let
      isLinux = pkgs.stdenv.hostPlatform.isLinux;
    in
    {
      programs.ghostty.settings = lib.mkIf isLinux {
        keybind = [
          "ctrl+c=copy_to_clipboard"
          "ctrl+v=paste_from_clipboard"
          "ctrl+t=new_tab"
          "ctrl+w=close_surface"
          "ctrl+one=goto_tab:1"
          "ctrl+two=goto_tab:2"
          "ctrl+three=goto_tab:3"
          "ctrl+four=goto_tab:4"
          "ctrl+five=goto_tab:5"
          "ctrl+six=goto_tab:6"
          "ctrl+seven=goto_tab:7"
          "ctrl+eight=goto_tab:8"
          "ctrl+nine=goto_tab:9"
          "super+shift+2=text:\\x00"
          "super+a=text:\\x01"
          "super+b=text:\\x02"
          "super+c=text:\\x03"
          "super+d=text:\\x04"
          "super+e=text:\\x05"
          "super+f=text:\\x06"
          "super+g=text:\\x07"
          "super+h=text:\\x08"
          "super+i=text:\\x09"
          "super+j=text:\\x0a"
          "super+k=text:\\x0b"
          "super+l=text:\\x0c"
          "super+m=text:\\x0d"
          "super+n=text:\\x0e"
          "super+o=text:\\x0f"
          "super+p=text:\\x10"
          "super+q=text:\\x11"
          "super+r=text:\\x12"
          "super+s=text:\\x13"
          "super+t=text:\\x14"
          "super+u=text:\\x15"
          "super+v=text:\\x16"
          "super+w=text:\\x17"
          "super+x=text:\\x18"
          "super+y=text:\\x19"
          "super+z=text:\\x1a"
          "super+bracket_left=text:\\x1b"
          "super+backslash=text:\\x1c"
          "super+bracket_right=text:\\x1d"
          "super+shift+6=text:\\x1e"
          "super+slash=text:\\x1f"
        ];
      };

      programs.vscode.profiles.default.keybindings = lib.mkIf isLinux [
        {
          key = "ctrl+c";
          command = "workbench.action.terminal.copySelection";
          when = "terminalFocus";
        }
        {
          key = "ctrl+v";
          command = "workbench.action.terminal.paste";
          when = "terminalFocus";
        }
        {
          key = "meta+a";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0001"'';
          when = "terminalFocus";
        }
        {
          key = "meta+b";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0002"'';
          when = "terminalFocus";
        }
        {
          key = "meta+c";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0003"'';
          when = "terminalFocus";
        }
        {
          key = "meta+d";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0004"'';
          when = "terminalFocus";
        }
        {
          key = "meta+e";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0005"'';
          when = "terminalFocus";
        }
        {
          key = "meta+f";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0006"'';
          when = "terminalFocus";
        }
        {
          key = "meta+g";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0007"'';
          when = "terminalFocus";
        }
        {
          key = "meta+h";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0008"'';
          when = "terminalFocus";
        }
        {
          key = "meta+i";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0009"'';
          when = "terminalFocus";
        }
        {
          key = "meta+j";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u000a"'';
          when = "terminalFocus";
        }
        {
          key = "meta+k";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u000b"'';
          when = "terminalFocus";
        }
        {
          key = "meta+l";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u000c"'';
          when = "terminalFocus";
        }
        {
          key = "meta+m";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u000d"'';
          when = "terminalFocus";
        }
        {
          key = "meta+n";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u000e"'';
          when = "terminalFocus";
        }
        {
          key = "meta+o";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u000f"'';
          when = "terminalFocus";
        }
        {
          key = "meta+p";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0010"'';
          when = "terminalFocus";
        }
        {
          key = "meta+q";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0011"'';
          when = "terminalFocus";
        }
        {
          key = "meta+r";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0012"'';
          when = "terminalFocus";
        }
        {
          key = "meta+s";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0013"'';
          when = "terminalFocus";
        }
        {
          key = "meta+t";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0014"'';
          when = "terminalFocus";
        }
        {
          key = "meta+u";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0015"'';
          when = "terminalFocus";
        }
        {
          key = "meta+v";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0016"'';
          when = "terminalFocus";
        }
        {
          key = "meta+w";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0017"'';
          when = "terminalFocus";
        }
        {
          key = "meta+x";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0018"'';
          when = "terminalFocus";
        }
        {
          key = "meta+y";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u0019"'';
          when = "terminalFocus";
        }
        {
          key = "meta+z";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u001a"'';
          when = "terminalFocus";
        }
        {
          key = "meta+[";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u001b"'';
          when = "terminalFocus";
        }
        {
          key = "meta+\\";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u001c"'';
          when = "terminalFocus";
        }
        {
          key = "meta+]";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u001d"'';
          when = "terminalFocus";
        }
        {
          key = "meta+/";
          command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u001f"'';
          when = "terminalFocus";
        }
      ];
    };
}
