--------------------------------------------------
-- BASIC EDITOR SETTINGS (VS Code–like)
--------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "yes"
vim.opt.softtabstop = 4

------------------------------------------------------
-- MAKEFILE SPECIFIC
vim.api.nvim_create_autocmd("FileType", {
  pattern = "make",
  callback = function()
    vim.opt_local.expandtab = false
  end
})

--------------------------------------------------
-- LAZY.NVIM (PLUGIN MANAGER)
--------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------
-- PLUGINS
--------------------------------------------------
require("lazy").setup({

  ------------------------------------------------
  -- FILE EXPLORER (VS Code sidebar)
  ------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = { group_empty = true }
      })
    end
  },

  ------------------------------------------------
  -- TABS (buffer line)
  ------------------------------------------------
  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({})
    end
  },

  ------------------------------------------------
  -- STATUS LINE
  ------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("lualine").setup({
        options = { theme = "auto" }
      })
    end
  },

  ------------------------------------------------
  -- FUZZY FINDER (Ctrl+P)
  ------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
    end
  },

  ------------------------------------------------
  -- AUTOCOMPLETION
  ------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = {
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        },
        sources = {
          { name = "nvim_lsp" },
        }
      })
    end
  },

  ------------------------------------------------
  -- LSP (Neovim 0.11+ native API, NOT deprecated)
  ------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    config = function()

      -- Define LSP servers using Neovim core
      vim.lsp.config("pyright", {})
      vim.lsp.config("rust_analyzer", {})

      -- Enable them
      vim.lsp.enable("pyright")
      vim.lsp.enable("rust_analyzer")

    end
  },

  ------------------------------------------------
  -- THEME
  ------------------------------------------------
  {
    "folke/tokyonight.nvim",
    config = function()
      vim.cmd("colorscheme tokyonight")
    end
  },

})

--------------------------------------------------
-- KEYBINDINGS (VS Code–like)
--------------------------------------------------
local map = vim.keymap.set

-- File explorer
map("n", "<C-b>", ":NvimTreeToggle<CR>")

-- Fuzzy find (Ctrl+P)
map("n", "<C-p>", ":Telescope find_files<CR>")

-- Search in project
map("n", "<C-f>", ":Telescope live_grep<CR>")

--------------------------------------------------
-- LSP KEYBINDS (VS Code feel)
--------------------------------------------------
map("n", "gd", vim.lsp.buf.definition)
map("n", "gr", vim.lsp.buf.references)
map("n", "K", vim.lsp.buf.hover)
map("n", "<F2>", vim.lsp.buf.rename)
map("n", "<F12>", vim.lsp.buf.definition)
map("n", "<leader>ca", vim.lsp.buf.code_action)

--------------------------------------------------
-- INSERT MODE: VS CODE–LIKE KEYBINDINGS
--------------------------------------------------

-- Save
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a")

-- Quit
vim.keymap.set("i", "<C-x>", "<Esc>:q<CR>")

-- Save & Exit
vim.keymap.set("i", "<C-S-s>", "<Esc>:wq<CR>")

-- Exit without Saving
vim.keymap.set("i", "<C-S-x>", "<Esc>:q!<CR>")
