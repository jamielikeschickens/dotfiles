-- Set some basic vim settings
vim.opt.number = true
vim.g.mapleader = ","
vim.opt.termguicolors = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Make buffer navigation easier
vim.keymap.set("n", "<Leader>bn", ":bn<cr>")
vim.keymap.set("n", "<Leader>bp", ":bp<cr>")
vim.keymap.set("n", "<Leader>bd", ":bd<cr>")

-- Open a split with the go to definition
local function go_to_definition_split()
  vim.cmd('rightbelow vsplit')
  vim.lsp.buf.definition()
end
vim.keymap.set('n', 'gds', go_to_definition_split)


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
    configs.setup {
        ensure_installed = { "python" },
        auto_install = true,
        highlight = {
            enable = true,
        }
    }
end


require("lazy").setup(
{
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    { "ms-jpq/coq_nvim", branch="coq" },
    { "ms-jpq/coq.artifacts", branch="artifacts" },
    { "ms-jpq/coq.thirdparty", branch="3p" },
    { "nvim-treesitter/nvim-treesitter", config=treesitter_config, build=':TSUpdate' },
    "sainnhe/sonokai",
    { 'nvim-telescope/telescope.nvim', tag = '0.1.5',
      dependencies = { 'nvim-lua/plenary.nvim' }
      },
      { "nvim-tree/nvim-tree.lua",
      version = "*",
      dependencies = {
          "nvim-tree/nvim-web-devicons",
      },
      config = function()
          require("nvim-tree").setup {}
      end
    },
    { "nvim-lualine/lualine.nvim" },
    { "akinsho/bufferline.nvim" },
    { "jose-elias-alvarez/null-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" }
    },
    { "zbirenbaum/copilot.lua", config=function() require("copilot").setup({}) end},
    { "PedramNavid/dbtpal" },
    { "NeogitOrg/neogit",
      dependencies = {
        "nvim-lua/plenary.nvim",         -- required
        "sindrets/diffview.nvim",        -- optional - Diff integration
        "nvim-telescope/telescope.nvim", -- optional
      },
      config = {
            kind="auto"
        }
    }
})

-- null-ls setup for formatting
local null_ls = require("null-ls")
local null_ls_sources = {
--    null_ls.builtins.formatting.prettier.with({
--        extra_args = function(params)
--            return params.options
--            and params.options.tabSize
--            and {
--                "--tab-width",
--                params.options.tabSize,
--            }
--        end,
--    }),
    null_ls.builtins.formatting.black
}

null_ls.setup({
    sources = null_ls_sources,
    -- on_attach setups up so we automatically call format each time we save with null-ls
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ async = false })
                end,
            })
        end
    end,
})

-- Format buffer using null-ls/lsp configs
vim.keymap.set("", "<Leader>bf", function() vim.lsp.buf.format({ async = false }) end)


-- mason setup for installing lsp configurations
require("mason").setup()
require("mason-lspconfig").setup {
    ensure_installed = { "ts_ls", "dockerls", "jsonls", "marksman", "jedi_language_server" },
}

local coq = require("coq")
local lspconfig = require('lspconfig')
lspconfig.jedi_language_server.setup(coq.lsp_ensure_capabilities())
lspconfig.ts_ls.setup{}

-- lsp keybinding
-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<Leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<Leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  end,
})


vim.cmd.colorscheme("sonokai")

-- Telescope settings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>ft', builtin.treesitter, {})

-- Settings for nvim-tree
-- Stop netrw from being loaded vim's default file explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local nvim_tree_api = require("nvim-tree.api")
vim.keymap.set('n', '<leader>nt', nvim_tree_api.tree.toggle, {})

-- lualine setup
require('lualine').setup()

-- bufferline setup
require("bufferline").setup{}

-- terminal mode remaps
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true }) -- escape, escapes terminal mode

-- remap so Ctrl-R behaviour works
function _G.escape_and_insert_char()
  local char = vim.fn.nr2char(vim.fn.getchar())
  return '<C-\\><C-N>"' .. char .. 'pi'
end
vim.api.nvim_set_keymap(
  't',
  '<C-R>',
  'v:lua.escape_and_insert_char()',
  { expr = true, noremap = true, silent = true }
)



