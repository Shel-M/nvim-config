vim.api.nvim_create_user_command("E", "Explore", {})

vim.o.number = true                    -- Turn on line numbers
vim.o.relativenumber = true            -- Make line numbers relative to current cursor position
vim.o.mouse = "a"                      -- Enable mouse mode
vim.o.showmode = false                 -- Don't show mode, it's in the status line
vim.o.breakindent = true               -- Make visual line breaks indent for readability
vim.o.undofile = true                  -- Save undos between sessions
vim.o.ignorecase = true                -- Ignore case in search mode
vim.o.smartcase = true                 -- Unless \C or capital letter is in the search
vim.o.signcolumn = "yes"               -- Display a gutter for signs (ex. git-signs plugin draws here)
vim.o.updatetime = 250                 -- Decrease time between swap file writes
vim.o.timeoutlen = 300                 -- Decrease timeout for hotkeys
vim.o.splitright = true                -- Allow new splits to the right
vim.o.list = true                      -- Allow lists for options.
vim.o.inccommand = "split"             -- Live preview substitutions
vim.o.scrolloff = 10                   -- Number of lines to keep above and below the cursor
vim.o.confirm = true                   -- Confirm write instead of requiring ! eg: :q!

vim.o.hlsearch = false                 -- Set highlight on search
vim.o.completeopt = "menuone,noselect" -- Set completion dialogs
vim.o.termguicolors = true             -- Turn on full color terminal support
vim.o.linebreak = true                 -- Turn on visual line breaks

-- Configure vim sessionoptions for auto-session plugin
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Schedule this setting to improve startup time.
vim.schedule(function()
	vim.o.clipboard = "unnamedplus" -- Integrate system clipboard
end)

-- Enables automatic format on save via LSP
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

-- Configure templ extension
vim.filetype.add {
	extension = {
		templ = "templ",
	},
}
