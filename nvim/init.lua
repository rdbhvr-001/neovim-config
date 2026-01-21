-- init.lua
-- Robust Neovim 0.11+ config (lazy.nvim). With no nvim-treesitter

--------------------------------------------------
-- LEADER (first thing)
--------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--------------------------------------------------
-- BASIC EDITOR SETTINGS
--------------------------------------------------
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.termguicolors = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.signcolumn = "yes"
opt.cursorline = true
opt.wrap = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.linebreak = true
opt.breakindent = true
--------------------------------------------------
-- FILETYPE-SPECIFIC: MAKEFILES (use real tabs)
--------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "make",
  callback = function() vim.opt_local.expandtab = false end,
})

--------------------------------------------------
-- BOOTSTRAP lazy.nvim (folke/lazy.nvim)
--------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------
-- PLUGINS (lazy.nvim)
--------------------------------------------------
require("lazy").setup({

  ----------------------------------------------------------------
  -- ICONS
  ----------------------------------------------------------------
  { "nvim-tree/nvim-web-devicons", lazy = true },

  ----------------------------------------------------------------
  -- THEME (load early)
  ----------------------------------------------------------------
  -- THEMES
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function() vim.cmd.colorscheme("tokyonight") end,
  },

  {
    "rebelot/kanagawa.nvim",
    config = function() end,  -- load manually when switching
  },

  {
    "EdenEast/nightfox.nvim",
    config = function() end,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function() end,
  },


  ----------------------------------------------------------------
  -- FILE EXPLORER (sidebar)
  ----------------------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = { group_empty = true },
        filters = { dotfiles = false },
      })
    end,
  },

  ----------------------------------------------------------------
  -- BUFFERLINE (tabs)
  ----------------------------------------------------------------
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              highlight = "Directory",
              separator = true,
            },
          },
        },
      })
    end,
  },

  ----------------------------------------------------------------
  -- STATUSLINE
  ----------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "auto", section_separators = "", component_separators = "" },
      })
    end,
  },

  ----------------------------------------------------------------
  -- TELESCOPE (fuzzy finder)
  ----------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
          winblend = 10,
        },
      })
    end,
  },

  ----------------------------------------------------------------
  -- SNIPPETS (LuaSnip)
  ----------------------------------------------------------------
  {
    "L3MON4D3/LuaSnip",
    build = nil,
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  ----------------------------------------------------------------
  -- AUTOCOMPLETE (nvim-cmp + sources)
  ----------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local ok_cmp, cmp = pcall(require, "cmp")
      if not ok_cmp then return end
      local ok_snip, luasnip = pcall(require, "luasnip")
      if not ok_snip then luasnip = nil end

      cmp.setup({
        snippet = {
          expand = function(args)
            if luasnip then luasnip.lsp_expand(args.body) end
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip and luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip and luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },

  ----------------------------------------------------------------
  -- LSP CONFIG (native API for Neovim 0.11+)
  ----------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- global diagnostics
      vim.diagnostic.config({
        virtual_text = false,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "always" },
      })
      vim.lsp.handlers["textDocument/hover"] =
        vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

      -- build capabilities with cmp_nvim_lsp if present
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmpn, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmpn and cmp_nvim_lsp then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      -- minimal on_attach placeholder (customize later as needed)
      local on_attach = function(client, bufnr)
        -- buffer-local keymaps and options can be set here if required
      end

      -- configure servers using native vim.lsp API (vim.lsp.config + vim.lsp.enable)
      vim.lsp.config("pyright", {
        capabilities = capabilities,
        on_attach = on_attach,
      })
      vim.lsp.enable("pyright")
      vim.lsp.config("rust_analyzer", {
        settings = {
            ["rust-analyzer"] = {
            checkOnSave = true,  -- boolean
                }
            }
      })
      vim.lsp.enable("rust_analyzer")
    end,
  },

  ----------------------------------------------------------------
  -- DASHBOARD (alpha)
  ----------------------------------------------------------------
  {
    "goolord/alpha-nvim",
    config = function()
      local ok, alpha = pcall(require, "alpha")
      if ok and alpha then
        alpha.setup(require("alpha.themes.dashboard").config)
      end
    end,
  },

}, {
  checker = { enabled = true },
  performance = { rtp = { disabled_plugins = { "gzip", "tohtml", "tarPlugin", "zipPlugin" } } },
})

--------------------------------------------------
-- KEYMAPS (concise)
--------------------------------------------------
local map = vim.keymap.set
-- Explorer
map("n", "<C-m>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
-- Telescope
map("n", "<C-f>", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<C-g>", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })

-- LSP
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "References" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

-- INSERT MODE: VS Code–like
map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save (insert mode)" })
map("i", "<C-x>", "<Esc>:q<CR>", { desc = "Quit (insert mode)" })
map("i", "<C-S-s>", "<Esc>:wq<CR>", { desc = "Save & Quit (insert mode)" })
map("i", "<C-S-x>", "<Esc>:q!<CR>", { desc = "Quit no save (insert mode)" })

--------------------------------------------------
-- OPTIONAL TWEAKS / SANE DEFAULTS
--------------------------------------------------
vim.o.updatetime = 250
vim.o.lazyredraw = true

--------------------------------------------------
-- USAGE: after placing this file
-- 1) Launch nvim
-- 2) Run :Lazy sync
--------------------------------------------------

-- End of file
