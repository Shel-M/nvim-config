vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remaps to handle word wrap - allows up and down motions to transit to wrapped lines
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Allow highlighted move
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Diagnostic messages
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>E", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Lsp keymap
vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

-- Telescope
vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
vim.keymap.set("n", "<leader><space>", require("telescope.builtin").buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>/", function()
	require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
		winblend = 10,
		previewer = false,
	})
end, { desc = "[/] Fuzzily search in current buffer" })

-- Searching keymaps
vim.keymap.set("n", "<leader>gf", require("telescope.builtin").git_files, { desc = "Search [G]it [F]iles" })
vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "[F]ind [F]iles" })
vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>fw", require("telescope.builtin").grep_string, { desc = "[F]ind current [W]ord" })
vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "[F]ind by [G]rep" })
vim.keymap.set("n", "<leader>fG", ":LiveGrepGitRoot<cr>", { desc = "[F]ind by [G]rep on Git root" })
vim.keymap.set("n", "<leader>fd", require("telescope.builtin").diagnostics, { desc = "[F]ind [D]iagnostics" })
vim.keymap.set("n", "<leader>fr", require("telescope.builtin").resume, { desc = "[F]ind [R]esume" })

-- Insert newline at cursor
vim.keymap.set("n", "<C-j>", "R<cr><esc>k$")

-- Ctrl+Windows ergonomics rebinds
vim.keymap.set("n", "<leader>ws", "<C-w>v", { desc = "[S]plit" })
vim.keymap.set("n", "<leader>w>", "<C-w>>", { desc = "Increase split width" })
vim.keymap.set("n", "<leader>w<", "<C-w><", { desc = "Decrease split width" })
vim.keymap.set("n", "<leader>wS", "<C-w>s", { desc = "[S]plit horizontal" })
vim.keymap.set("n", "<leader>w+", "<C-w>+", { desc = "Increase split height" })
vim.keymap.set("n", "<leader>w<", "<C-w>-", { desc = "Decrease split height" })
vim.keymap.set("n", "<leader>ww", "<C-w>w", { desc = "S[w]itch windows" })
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Move to down window" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Move to up window" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Move to right window" })
vim.keymap.set("n", "<leader>wx", "<C-w>x", { desc = "Swap windows" })
vim.keymap.set("n", "<leader>wt", "<C-w>T", { desc = "Open [t]ab" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Equal height and width" })
vim.keymap.set("n", "<leader>wq", "<C-w>q", { desc = "[Q]uit" })
vim.keymap.set("n", "<leader>wQ", "<C-w>o", { desc = "[Q]uit others" })

-- Save and close binds
vim.keymap.set("n", "<leader>s", ":w<cr>", { desc = "[S]ave" })
vim.keymap.set("n", "<leader>S", ":wa<cr>", { desc = "[S]ave all" })
vim.keymap.set("n", "<leader>q", ":xa<cr>", { desc = "Save and [Q]uit" })
vim.keymap.set("n", "<leader>Q", ":qa!<cr>", { desc = "[Q]uit without save" })
