{
  homeManager =
    { pkgs, ... }:
    {
      xdg.configFile."rumdl/rumdl.toml".text = ''
        [MD013]
        line-length = 80
        reflow = true
      '';

      home.packages = with pkgs; [
        # Rust
        cargo
        rust-analyzer
        rustc
        rustfmt
        clippy

        # Go
        go
        gopls

        # JavaScript / TypeScript
        nodejs
        prettier
        typescript
        typescript-language-server

        # Python
        python3

        # Nix
        nil
        nixfmt

        # Shell
        bash-language-server
        shellcheck
        shfmt

        # Markdown
        rumdl

        # TOML
        taplo

        # YAML
        yaml-language-server
        yamlfmt
      ];
    };
}
