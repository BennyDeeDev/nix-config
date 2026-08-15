{
  homeManager =
    {
      config,
      dotfiles,
      pkgs,
      ...
    }:
    {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        plugins = with pkgs.vimPlugins; [
          catppuccin-nvim
          no-neck-pain-nvim
          fzf-lua
          gitsigns-nvim
          conform-nvim
          blink-cmp
          toggleterm-nvim
          roslyn-nvim
          nvim-autopairs

          (nvim-treesitter.withPlugins (p: [
            p.lua
            p.nix
            p.zig
            p.json
            p.toml
            p.yaml
            p.markdown
            p.markdown_inline
            p.bash
            p.just
            p.gdscript
            p.c_sharp
          ]))
        ];
      };

      home.packages = with pkgs; [
        nixd
        lua-language-server
        zls
        roslyn-ls

        nixfmt
        stylua
        taplo
        shfmt
        just
        gdtoolkit_4
        csharpier

        fd
        ripgrep
        bat
        # Delta is retained for editor Git previews rather than as a general CLI dependency.
        delta
      ];

      xdg.configFile."nvim/init.lua".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/files/neovim/init.lua";
    };
}
