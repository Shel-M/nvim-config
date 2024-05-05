-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
                vim.highlight.on_yank()
        end,
        group = highlight_group,
        pattern = "*",
})

-- Harpoon config
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>hh", mark.add_file, { desc = "[H]arpoon file" })
vim.keymap.set("n", "<leader>hm", ui.toggle_quick_menu, { desc = "[H]arpoon [M]enu" })

vim.keymap.set("n", "<leader>n", function() ui.nav_file(1) end, { desc = "File 1" })
vim.keymap.set("n", "<leader>e", function() ui.nav_file(2) end, { desc = "File 2" })
vim.keymap.set("n", "<leader>i", function() ui.nav_file(3) end, { desc = "File 3" })
vim.keymap.set("n", "<leader>o", function() ui.nav_file(4) end, { desc = "File 4" })

-- Telescope config
require("telescope").setup {
        defaults = {
                mappings = {
                        i = {
                                ["<C-u>"] = false,
                                ["<C-d>"] = false,
                        },
                },
        },
}
pcall(require("telescope").load_extension, "fzf")

-- Telescope grep in git root
local function find_git_root()
        local current_file = vim.api.nvim_buf_get_name(0)
        local current_dir
        local cwd = vim.fn.getcwd()

        if current_file == "" then
                current_dir = cwd
        else
                current_dir = vim.fn.fnamemodify(current_file, ":h")
        end

        local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")
            [1]
        if vim.v.shell_error ~= 0 then
                print("Not a git repository. Searching on current working directory")
                return cwd
        end
        return git_root
end

local function live_grep_git_root()
        local git_root = find_git_root()
        if git_root then
                require("telescope.builtin").live_grep({
                        search_dirs = { git_root },
                })
        end
end

vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})

-- Configure Treesitter
vim.defer_fn(function()
        require("nvim-treesitter.configs").setup {
                ensure_installed = { "rust", "go", "bash", "lua" }, -- Default language installation
                auto_install = true,                                -- Automatically install new languages as detected.

                highlight = {
                        enable = true,
                        additional_vim_regex_highlighting = false
                },
                indent = { enable = true },
                incremental_selection = {
                        enable = true,
                        keymaps = {
                                init_selection = '<c-space>',
                                node_incremental = '<c-space>',
                                scope_incremental = '<c-s>',
                                node_decremental = '<M-space>',
                        },
                },
                textobjects = {
                        select = {
                                enable = true,
                                lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                                keymaps = {
                                        -- You can use the capture groups defined in textobjects.scm
                                        ['aa'] = '@parameter.outer',
                                        ['ia'] = '@parameter.inner',
                                        ['af'] = '@function.outer',
                                        ['if'] = '@function.inner',
                                        ['ac'] = '@class.outer',
                                        ['ic'] = '@class.inner',
                                },
                        },
                        move = {
                                enable = true,
                                set_jumps = true, -- whether to set jumps in the jumplist
                                goto_next_start = {
                                        [']m'] = '@function.outer',
                                        [']]'] = '@class.outer',
                                },
                                goto_next_end = {
                                        [']M'] = '@function.outer',
                                        [']['] = '@class.outer',
                                },
                                goto_previous_start = {
                                        ['[m'] = '@function.outer',
                                        ['[['] = '@class.outer',
                                },
                                goto_previous_end = {
                                        ['[M'] = '@function.outer',
                                        ['[]'] = '@class.outer',
                                },
                        },
                        swap = {
                                enable = true,
                                swap_next = {
                                        ['<leader>a'] = '@parameter.inner',
                                },
                                swap_previous = {
                                        ['<leader>A'] = '@parameter.inner',
                                },
                        },
                },
        }

        local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
        parser_config.hypr = {
                install_info = {
                        url = "https://github.com/luckasRanarison/tree-sitter-hypr",
                        files = { "src/parser.c" },
                        branch = "master",
                },
                filetype = "hypr",
        }
end, 0)

-- Configure LSP
local lsp_zero = require("lsp-zero")
lsp_zero.on_attach(function(client, bufnr)
        lsp_zero.default_keymaps({ buffer = bufnr, preserve_mappings = false })
end)

require("mason").setup({})
require("mason-lspconfig").setup({
        ensure_installed = {},
        handlers = { lsp_zero.default_setup },
})

require("which-key").register {
        ["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
        ["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
        ["<leader>g"] = { name = "[G]it", _ = "which_key_ignore" },
        ["<leader>h"] = { name = "[H]arpoon", _ = "which_key_ignore" },
        ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
        ["<leader>f"] = { name = "[F]ind", _ = "which_key_ignore" },
        ["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
}

require("neodev").setup()

-- Configure completion
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
luasnip.config.setup {}

cmp.setup {
        snippet = {
                expand = function(args)
                        luasnip.lsp_expand(args.body)
                end,
        },
        completion = {
                completeopt = "menu,menuone,noinsert"
        },
        mapping = cmp.mapping.preset.insert {
                ["<C-n>"] = cmp.mapping.select_next_item(),
                ["<C-p>"] = cmp.mapping.select_prev_item(),
                ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete {},
                ["<CR>"] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                },
                ["<Down>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                                cmp.select_next_item()
                        elseif luasnip.expand_or_locally_jumpable() then
                                luasnip.expand_or_jump()
                        else
                                fallback()
                        end
                end, { "i", "s" }),
                ["<Up>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                                cmp.select_prev_item()
                        elseif luasnip.locally_jumpable(-1) then
                                luasnip.jump(-1)
                        else
                                fallback()
                        end
                end, { "i", "s" }),
        },
        sources = {
                { name = "codeium" },
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "crates.nvim" },
        },
}

-- Configure colorizer
vim.o.termguicolors = true -- Turn on full color terminal support
require("colorizer").setup()
