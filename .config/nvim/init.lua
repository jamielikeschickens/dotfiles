-- Set some basic vim settings
vim.opt.number = true
vim.g.mapleader = ","
vim.opt.termguicolors = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true

-- Make buffer navigation easier
vim.keymap.set("n", "<Leader>bn", ":bn<cr>")
vim.keymap.set("n", "<Leader>bp", ":bp<cr>")
vim.keymap.set("n", "<Leader>bd", ":bd<cr>")

-- Open a split with the go to definition
local function go_to_definition_split()
	vim.cmd("rightbelow vsplit")
	vim.lsp.buf.definition()
end
vim.keymap.set("n", "gds", go_to_definition_split)

-- Copy the current file path to paste register
vim.keymap.set("n", "<Leader>cp", ':let @" = expand("%")<cr>')

-- Easy to hide search highlight after searching
vim.keymap.set("n", "<Leader><cr>", ":noh<cr>")

-- coq settings must be set before required
vim.g.coq_settings = { auto_start = "shut-up" }

-- tab settings
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- load plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local treesitter_config = function()
	local configs = require("nvim-treesitter.configs")
	configs.setup({
		ensure_installed = { "python" },
		auto_install = true,
		highlight = {
			enable = true,
		},
	})
end

require("lazy").setup({
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig",
	{ "ms-jpq/coq_nvim", branch = "coq" },
	{ "ms-jpq/coq.artifacts", branch = "artifacts" },
	{ "ms-jpq/coq.thirdparty", branch = "3p" },
	{ "nvim-treesitter/nvim-treesitter", config = treesitter_config, build = ":TSUpdate" },
	"sainnhe/sonokai",
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-ui-select.nvim" },
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})

			-- Load the extension
			telescope.load_extension("ui-select")
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup({})
		end,
	},
	{ "nvim-lualine/lualine.nvim" },
	{ "akinsho/bufferline.nvim" },
	{
		"zbirenbaum/copilot.lua",
		config = function()
			require("copilot").setup({})
		end,
	},
	{ "PedramNavid/dbtpal" },
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration
			"nvim-telescope/telescope.nvim", -- optional
		},
		config = {
			kind = "auto",
		},
	},
	{
		"folke/trouble.nvim",
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		opts = {
			-- See Configuration section for options
		},
		config = function(_, opts)
			local chat = require("CopilotChat")
			chat.setup(opts)

			local select = require("CopilotChat.select")
			vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
				chat.ask(args.args, { selection = select.visual })
			end, { nargs = "*", range = true })

			-- Inline chat with Copilot
			vim.api.nvim_create_user_command("CopilotChatInline", function(args)
				chat.ask(args.args, {
					selection = select.visual,
					window = {
						layout = "float",
						relative = "cursor",
						width = 1,
						height = 0.4,
						row = 1,
					},
				})
			end, { nargs = "*", range = true })

			-- Restore CopilotChatBuffer
			vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
				chat.ask(args.args, { selection = select.buffer })
			end, { nargs = "*", range = true })

			-- Custom buffer for CopilotChat
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-*",
				callback = function()
					vim.opt_local.relativenumber = true
					vim.opt_local.number = true
					-- Unset conflicting LSP mappings in this buffer
					vim.keymap.set("n", "gd", "<Nop>", opts)
					vim.keymap.set("n", "gi", "<Nop>", opts)
					vim.keymap.set("n", "gr", "<Nop>", opts)
					vim.keymap.set("n", "K", "<Nop>", opts)
					vim.keymap.set("n", "gD", "<Nop>", opts)
					vim.keymap.set("n", "gc", "<Nop>", opts)
					vim.keymap.set("n", "gy", "<Nop>", opts)

					-- Get current filetype and set it to markdown if the current filetype is copilot-chat
					local ft = vim.bo.filetype
					if ft == "copilot-chat" then
						vim.bo.filetype = "markdown"
					end
				end,
			})
		end,
		keys = {
			{
				"<leader>ap",
				function()
					require("CopilotChat").select_prompt({
						context = {
							"buffers",
						},
					})
				end,
				desc = "CopilotChat - Prompt actions",
			},
			{
				"<leader>ap",
				function()
					require("CopilotChat").select_prompt()
				end,
				mode = "x",
				desc = "CopilotChat - Prompt actions",
			},
			-- Code related commands
			{ "<leader>ae", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
			{ "<leader>at", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
			{ "<leader>ar", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
			{ "<leader>aR", "<cmd>CopilotChatRefactor<cr>", desc = "CopilotChat - Refactor code" },
			{ "<leader>an", "<cmd>CopilotChatBetterNamings<cr>", desc = "CopilotChat - Better Naming" },
			-- Chat with Copilot in visual mode
			{
				"<leader>av",
				":CopilotChatVisual",
				mode = "x",
				desc = "CopilotChat - Open in vertical split",
			},
			{
				"<leader>ax",
				":CopilotChatInline",
				mode = "x",
				desc = "CopilotChat - Inline chat",
			},
			-- Custom input for CopilotChat
			{
				"<leader>ai",
				function()
					local input = vim.fn.input("Ask Copilot: ")
					if input ~= "" then
						vim.cmd("CopilotChat " .. input)
					end
				end,
				desc = "CopilotChat - Ask input",
			},
			-- Generate commit message based on the git diff
			{
				"<leader>am",
				"<cmd>CopilotChatCommit<cr>",
				desc = "CopilotChat - Generate commit message for all changes",
			},
			-- Quick chat with Copilot
			{
				"<leader>aq",
				function()
					local input = vim.fn.input("Quick Chat: ")
					if input ~= "" then
						vim.cmd("CopilotChatBuffer " .. input)
					end
				end,
				desc = "CopilotChat - Quick chat",
			},
			-- Fix the issue with diagnostic
			{ "<leader>af", "<cmd>CopilotChatFixError<cr>", desc = "CopilotChat - Fix Diagnostic" },
			-- Clear buffer and chat history
			{ "<leader>al", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Clear buffer and chat history" },
			-- Toggle Copilot Chat Vsplit
			{ "<leader>av", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },
			-- Copilot Chat Models
			{ "<leader>a?", "<cmd>CopilotChatModels<cr>", desc = "CopilotChat - Select Models" },
			-- Copilot Chat Agents
			{ "<leader>aa", "<cmd>CopilotChatAgents<cr>", desc = "CopilotChat - Select Agents" },
		},
	},
})

require("telescope").load_extension("ui-select")

-- mason setup for installing lsp configurations
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "ts_ls", "dockerls", "jsonls", "marksman", "pyright" },
})

vim.lsp.config("pyright", coq.lsp_ensure_capabilities({}))

--local poetry_env = vim.fn.system("poetry env info -p"):gsub("\n", "")
--local coq = require "coq"
--vim.lsp.config('pylsp', coq.lsp_ensure_capabilities({
--    settings = {
--        pylsp = {
--            plugins = {
--                pycodestyle = { enabled = false },
--                pyflakes = { enabled = true },
--                rope = { enabled = true,
--                          extensionModules = {},
--                          python_path = poetry_env
--            },
--                rope_autoimport = { enabled = true },
--            },
--
--        }
--    }
--    })
--)

-- lsp keybinding
-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Don't set LSP keymaps in Copilot Chat buffers
		local ft = vim.bo[ev.buf].filetype
		if ft == "copilot-chat" then
			return
		end
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<Leader>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<Leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<Leader>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set("n", "<Leader>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<Leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	end,
})

vim.cmd.colorscheme("sonokai")

-- Telescope settings
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
vim.keymap.set("n", "<leader>ft", builtin.treesitter, {})

-- Settings for nvim-tree
-- Stop netrw from being loaded vim's default file explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local nvim_tree_api = require("nvim-tree.api")
vim.keymap.set("n", "<leader>nt", nvim_tree_api.tree.toggle, {})

-- lualine setup
require("lualine").setup()

-- bufferline setup
require("bufferline").setup({})

-- terminal mode remaps
vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true }) -- escape, escapes terminal mode

-- remap so Ctrl-R behaviour works
function _G.escape_and_insert_char()
	local char = vim.fn.nr2char(vim.fn.getchar())
	return '<C-\\><C-N>"' .. char .. "pi"
end
vim.api.nvim_set_keymap("t", "<C-R>", "v:lua.escape_and_insert_char()", { expr = true, noremap = true, silent = true })
