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

vim.keymap.set("n", "<leader>j", function() ui.nav_file(1) end, { desc = "File 1" })
vim.keymap.set("n", "<leader>k", function() ui.nav_file(2) end, { desc = "File 2" })
vim.keymap.set("n", "<leader>l", function() ui.nav_file(3) end, { desc = "File 3" })
vim.keymap.set("n", "<leader>;", function() ui.nav_file(4) end, { desc = "File 4" })

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

-- Treesitter non-default configs
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.hypr = {
        install_info = {
                url = "https://github.com/luckasRanarison/tree-sitter-hypr",
                files = { "src/parser.c" },
                branch = "master",
        },
        filetype = "hypr",
}


-- Configure LSP
local lsp_zero = require("lsp-zero")
lsp_zero.on_attach(function(client, bufnr)
        lsp_zero.default_keymaps({ buffer = bufnr, preserve_mappings = false })
end)

require("mason").setup({})
require("mason-lspconfig").setup({
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
                function(server_name)
                        if server_name == "tsserver" then
                                server_name = "ts_ls"
                        else
                                lsp_zero.default_setup(server_name)
                        end
                end,
                ["rust_analyzer"] = function() end,
        },
})

require("which-key").add(
        {
                { "<leader>c", group = "[C]ode" },
                { "<leader>g", group = "[G]it" },
                { "<leader>h", group = "[H]arpoon" },
                { "<leader>r", group = "[R]ename" },
                { "<leader>f", group = "[F]ind" },
                { "<leader>w", group = "[W]orkspace" },
        })

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
                -- { name = "codeium" },
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "crates.nvim" },
        },
}

-- Configure colorizer
vim.o.termguicolors = true -- Turn on full color terminal support
require("colorizer").setup()
