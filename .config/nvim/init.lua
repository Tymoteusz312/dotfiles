-- ========================================================================== --
-- 1. AUTOMATYCZNA INSTALACJA MENEDŻERA PAKIETÓW (LAZY.NVIM)                 --
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Błąd klonowania lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nWciśnij dowolny klawisz, aby wyjść..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ========================================================================== --
-- 2. OPCJE EDYTORA (USTAWIENIA VIM)                                          --
-- ========================================================================== --
vim.opt.tabstop = 4      -- Szerokość tabulatora
vim.opt.shiftwidth = 4   -- Szerokość wcięcia (np. po klamrach)
vim.opt.expandtab = true  -- Zamieniaj tabulatory na spacje
vim.opt.softtabstop = 4  -- Ułatwia usuwanie 4 spacji naraz
vim.opt.number = true    -- Ustawia widoczność numerów linii
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ========================================================================== --
-- 3. DEKLARACJA WTYCZEK W LAZY.NVIM                                         --
-- ========================================================================== --
require("lazy").setup({
  -- Motywy graficzne
  { 'Mofiqul/vscode.nvim' },
  { 'sainnhe/everforest' },
  
  -- Eksplorator plików
  { 'stevearc/oil.nvim' },
  
  -- Wyszukiwarka plików i tekstu (Telescope)
  {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Szukaj plików w projekcie" })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Szukaj tekstu w plikach" })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Lista otwartych kart" })
    end
  },
  -- Błyskawiczne komentowanie kodu (Comment.nvim)
  {
    'numToStr/Comment.nvim',
    opts = {},
  },

  -- Zbiorcza lista wszystkich błędów w projekcie (Trouble.nvim)
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Lista błędów w projekcie" },
    },
  },

  -- Główny silnik Mason
  { 
    "williamboman/mason.nvim", 
    config = function()
      require("mason").setup()
    end
  },
  
  -- Most automatycznie pobierający serwery
  { 
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" }, 
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "rust_analyzer", "clangd", "zls", "lua_ls" }
      })
    end
  },
  
  -- Wsparcie dla protokołów LSP i składni
  { "neovim/nvim-lspconfig" },
  { "ziglang/zig.vim" },
  
  -- Autouzupełnianie kodu
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  
  -- Automatyczne domykanie nawiasów
  {
      'windwp/nvim-autopairs',
      event = 'InsertEnter',
      config = true
  },
  
  -- Pasek statusu
  {
      'nvim-lualine/lualine.nvim',
      requires = {'nvim-tree/nvim-web-devicons', opt = true }
  },

  -- Bezpieczna deklaracja Treesitter
  { 
    "nvim-treesitter/nvim-treesitter", 
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "c", "cpp", "rust", "lua", "vim", "vimdoc", "query" },
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
    },
    config = function(_, opts)
      local status, ts_configs = pcall(require, "nvim-treesitter.configs")
      if status then
        ts_configs.setup(opts)
      end
    end
  }
})

-- ========================================================================== --
-- 4. KONFIGURACJA WTYCZEK (OIL, LUALINE, AUTOPAIRS)                          --
-- ========================================================================== --

require('telescope').setup({
  pickers = {
    buffers = {
      initial_mode = "normal",
    },
  },
})

require("oil").setup({
  default_file_explorer = true,
  columns = { "icon" },
  float = {
    padding = 2,
    max_width = 0,
    max_height = 0,
    border = "rounded",
  },
  view_options = {
    show_hidden = true,
    is_always_hidden = function(name, bufnr)
      return name == ".." or name == ".git"
    end,
  },
  keymaps = {
    ["g?"] = "actions.show_help",
    ["<CR>"] = "actions.select",
    ["<C-s>"] = "actions.select_vsplit",
    ["<C-h>"] = "actions.select_split",
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = "actions.close",
    ["-"] = "actions.parent",
    ["_"] = "actions.open_cwd",
    ["gs"] = "actions.change_sort",
    ["gx"] = "actions.open_external",
    ["g."] = "actions.toggle_hidden",
  },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Otwórz folder nadrzędny" })
vim.keymap.set("n", "<leader>e", function() require("oil").toggle_float() end, { desc = "Eksplorator plików (pływający)" })

require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = {left = '', right = ''},
    section_separators = {left = '', right = ''},
    disabled_filetypes = { statusline = {}, winbar = {} },
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileFormat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
})

require("nvim-autopairs").setup({ check_ts = true })

-- Konfiguracja motywu Everforest
vim.g.everforest_background = 'medium'
vim.g.everforest_enable_italic_comments = 1
vim.cmd[[colorscheme everforest]]

-- ========================================================================== --
-- 5. GLOBALNA KONFIGURACJA POKAZYWANIA BŁĘDÓW (DIAGNOSTYKA OBOK KODU)         --
-- ========================================================================== --
vim.diagnostic.config({
    virtual_text = {
        spacing = 4,
        prefix = "●",
    },
    severity_sort = true,
    underline = true,
    update_in_insert = true,
})

-- ========================================================================== --
-- 6. NATYWNA KONFIGURACJA LSP (VIM.LSP.CONFIG ZINTEGROWANE Z MASONEM)       --
-- ========================================================================== --
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local mason_bin_path = vim.fn.stdpath("data") .. "/mason/bin/"

-- 1. Konfiguracja C/C++
vim.lsp.config('clangd', {
    cmd = { mason_bin_path .. "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu", "--offset-encoding=utf-16" },
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
    end,
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
})

-- 2. Konfiguracja Zig
vim.lsp.config('zls', {
    cmd = { mason_bin_path .. "zls" },
    filetypes = {'zig', 'zir'},
    root_markers = {'build.zig', 'zls.json', '.git'},
    capabilities = capabilities,
    settings = {
        zls = { enable_autofix = true, warn_style = true }
    }
})

-- 3. Konfiguracja Rusta
vim.lsp.config("rust_analyzer", {
    cmd = { mason_bin_path .. "rust-analyzer" },
    filetypes = {'rs', 'rust'},
    root_markers = {'Cargo.toml', '.git'},
    capabilities = capabilities,
    settings = {
        ["rust-analyzer"] = {
            diagnostics = {
                enable = true,
                styleLints = { enable = true },
            },
            checkOnSave = { enable = false }, 
        },
    },
})

-- 4. Konfiguracja Lua
vim.lsp.config("lua_ls", {
    cmd = { mason_bin_path .. "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", "init.lua", ".git" },
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
})

-- Włączenie wszystkich serwerów
vim.lsp.enable('clangd')
vim.lsp.enable('zls')
vim.lsp.enable('rust_analyzer')
vim.lsp.enable('lua_ls')

vim.lsp.inlay_hint.enable(true)

-- ========================================================================== --
-- 7. SKRÓTY KLAWISZOWE DLA FUNKCJI LSP                                       --
-- ========================================================================== --
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Idź do definicji" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Pokaz dokumentację pod kursem" })

-- ========================================================================== --
-- 8. KONFIGURACJA AUTOUZUPEŁNIANIA (NVIM-CMP & LUASNIP)                     --
-- ========================================================================== --
-- ========================================================================== --
-- 6. POPRAWIONA KONFIGURACJA AUTOUZUPEŁNIANIA (NVIM-CMP & LUASNIP)           --
-- ========================================================================== --
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.confirm({ select = true })
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' }, 
        { name = 'buffer' },   
        { name = 'path' },     
    }),
})

