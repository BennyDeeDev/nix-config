vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.number = true
vim.opt.scrolloff = 16
vim.opt.clipboard = "unnamedplus"
vim.opt.statuscolumn = "%s%l  "
vim.opt.signcolumn = "yes"
vim.opt.title = true
vim.opt.titlestring = "%t - " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. " - nvim"
vim.opt.termguicolors = true
vim.opt.undofile = true

local roslyn = require("roslyn")
local autopairs = require("nvim-autopairs")
local gs = require("gitsigns")
local fzf = require("fzf-lua")
local blink = require("blink.cmp")
local conform = require("conform")
local neckpain = require("no-neck-pain")
local toggleterm = require("toggleterm")
local Terminal = require("toggleterm.terminal").Terminal

gs.setup({})

blink.setup({
	keymap = { preset = "enter" },
})

conform.setup({
	formatters = {
		zig_fmt = {
			command = "zig",
			args = { "fmt", "$FILENAME" },
			stdin = false,
		},
		just_fmt = {
			command = "just",
			args = { "--fmt", "--unstable", "--justfile", "$FILENAME" },
			stdin = false,
		},
	},
	formatters_by_ft = {
		lua = { "stylua" },
		nix = { "nixfmt" },
		zig = { "zig_fmt" },
		json = { "prettier" },
		jsonc = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		toml = { "taplo" },
		bash = { "shfmt" },
		sh = { "shfmt" },
		just = { "just_fmt" },
		gdscript = { "gdformat" },
		cs = { "csharpier" },
	},
	format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
	notify_on_error = false,
})

toggleterm.setup({ persist_size = false })

local term = Terminal:new({
	direction = "float",
	hidden = true,
	close_on_exit = false,
})
local vterm = Terminal:new({
	direction = "vertical",
	hidden = true,
	close_on_exit = false,
	on_close = function()
		if _G.NoNeckPain and not _G.NoNeckPain.state.enabled then
			vim.cmd("NoNeckPain")
		end
	end,
})
local lazygit = Terminal:new({ cmd = "lazygit", direction = "float", hidden = true })
local vlazygit = Terminal:new({
	cmd = "lazygit",
	direction = "vertical",
	hidden = true,
	on_close = function()
		if _G.NoNeckPain and not _G.NoNeckPain.state.enabled then
			vim.cmd("NoNeckPain")
		end
	end,
})
local just = Terminal:new({ cmd = "just", direction = "float", hidden = true, close_on_exit = false })
local vjust = Terminal:new({
	cmd = "just",
	direction = "vertical",
	hidden = true,
	close_on_exit = false,
	on_close = function()
		if _G.NoNeckPain and not _G.NoNeckPain.state.enabled then
			vim.cmd("NoNeckPain")
		end
	end,
})
local claude = Terminal:new({
	cmd = "claude --continue 2>/dev/null || claude",
	direction = "float",
	hidden = true,
	close_on_exit = false,
})
local vclaude = Terminal:new({
	cmd = "claude --continue 2>/dev/null || claude",
	direction = "vertical",
	hidden = true,
	close_on_exit = false,
	on_close = function()
		if _G.NoNeckPain and not _G.NoNeckPain.state.enabled then
			vim.cmd("NoNeckPain")
		end
	end,
})

neckpain.setup({
	width = 120,
	autocmds = {
		enableOnVimEnter = "safe",
	},
})

vim.cmd.colorscheme("catppuccin-nvim")

vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})

vim.lsp.config("nixd", {
	cmd = { "nixd" },
	filetypes = { "nix" },
	settings = {
		nixd = {
			formatting = {
				command = { "nixfmt" },
			},
		},
	},
})

vim.lsp.config("zls", {
	cmd = { "zls" },
	filetypes = { "zig" },
	root_markers = { "build.zig" },
})

vim.lsp.config("gdscript", {
	cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
	filetypes = { "gdscript" },
	root_markers = { "project.godot" },
})

vim.lsp.enable({ "lua_ls", "nixd", "zls", "gdscript" })

roslyn.setup({ exe = "Microsoft.CodeAnalysis.LanguageServer" })

autopairs.setup({})

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function(data)
		if vim.fn.isdirectory(data.file) == 1 then
			vim.cmd.bwipeout(data.buf)
			fzf.files({ cwd = data.file })
		elseif data.file == "" then
			fzf.files()
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua", "nix", "zig", "json", "jsonc", "toml", "yaml", "markdown", "bash", "sh", "just", "gdscript", "cs" },
	callback = function()
		vim.treesitter.start()
	end,
})

vim.keymap.set("n", "<leader><space>", "<cmd>FzfLua files<cr>")
vim.keymap.set("n", "<leader>r", "<cmd>FzfLua oldfiles<cr>")
vim.keymap.set("n", "<leader>p", "<cmd>FzfLua files cwd=~/Repos<cr>")
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>b", "<cmd>FzfLua buffers<cr>")
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua live_grep<cr>")

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")
vim.keymap.set("n", "<C-S>", "<cmd>w<cr>")
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "<S-h>", ":bprev<CR>", { silent = true })

vim.keymap.set("n", "<leader>t", function()
	term:toggle()
end)
vim.keymap.set("n", "<leader>T", function()
	vterm:toggle(vim.o.columns * 0.5)
end)
vim.keymap.set("n", "<leader>j", function()
	just:toggle()
end)
vim.keymap.set("n", "<leader>J", function()
	vjust:toggle(vim.o.columns * 0.5)
end)
vim.keymap.set("n", "<leader>g", function()
	lazygit:toggle()
end)
vim.keymap.set("n", "<leader>G", function()
	vlazygit:toggle(vim.o.columns * 0.5)
end)
vim.keymap.set("n", "<leader>c", function()
	claude:toggle()
end)
vim.keymap.set("n", "<leader>C", function()
	vclaude:toggle(vim.o.columns * 0.5)
end)

vim.keymap.set("n", "<leader>s", "<cmd>FzfLua git_status<cr>")

vim.keymap.set("n", "<leader>Y", ":%y+<cr>")
vim.keymap.set("n", "<leader>L", function()
	local ref = vim.fn.expand("%") .. ":" .. vim.fn.line(".")
	vim.fn.setreg("+", ref)
	vim.notify(ref)
end)
vim.keymap.set("n", "<leader>P", 'ggVG"+p')

vim.keymap.set("n", "<leader>hr", gs.reset_hunk)
vim.keymap.set("n", "<leader>hR", gs.reset_buffer)
vim.keymap.set("n", "<leader>hi", gs.preview_hunk_inline)
