vim.o.hlsearch = false                 -- Set highlight on search
vim.o.mouse = "a"                      -- Enable mouse mode
vim.o.clipboard = "unnamedplus"        -- Integrate system clipboard
vim.o.breakindent = true               -- Make visual line breaks indent for readability
vim.o.undofile = true                  -- Save undos between sessions
vim.o.ignorecase = true                -- Ignore case in search mode
vim.o.smartcase = true                 -- Unless \C or capital letter is in the search
vim.o.updatetime = 250                 -- Decrease time between swap file writes
vim.o.timeoutlen = 300                 -- Decrease timeout for hotkeys
vim.o.completeopt = "menuone,noselect" -- Set completion dialogs
vim.o.termguicolors = true             -- Turn on full color terminal support

vim.opt.linebreak = true               -- Turn on visual line breaks

vim.wo.number = true                   -- Turn on line numbers
vim.wo.relativenumber = true           -- Make line numbers relative to current cursor position
vim.wo.signcolumn = "yes"              -- Display a gutter for signs (ex. git-signs plugin draws here)

-- Enables automatic format on save via LSP
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]
