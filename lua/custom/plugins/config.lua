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
local on_attach = function(_, bufnr)
        local nmap = function(keys, func, desc)
                if desc then
                        desc = "LSP: " .. desc
                end
                vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
        end

        nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

        nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        nmap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "[T]ype [D]efinition")
        nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
        nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

        nmap("K", vim.lsp.buf.hover, "Hover Documentation")
        nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

        nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
        nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
        nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
        nmap("<leader>wl", function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folder()))
        end, "[W]orkspace [L]ist Folders")

        vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
                vim.lsp.buf.format()
        end, { desc = "Format current buffer with LSP" })
end

require("which-key").register {
        ["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
        ["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
        ["<leader>g"] = { name = "[G]it", _ = "which_key_ignore" },
        ["<leader>h"] = { name = "[H]arpoon", _ = "which_key_ignore" },
        ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
        ["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
        ["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
}

-- Setup and enable language servers
require("mason").setup()
require("mason-lspconfig").setup()
local servers = {
        gopls = {},
        pyright = {},
        html = { filetypes = { "html", "twig", "hbs" } },
        lua_ls = {
                Lua = {
                        workspace = { checkThirdPArty = false },
                        telemetry = { enable = false },
                },
        },
}

require("neodev").setup()

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Install servers
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
        function(server_name)
                require("lspconfig")[server_name].setup {
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = servers[server_name],
                        filetypes = (servers[server_name] or {}).filetypes,
                }
        end,
        ["rust_analyzer"] = function() end,
}

local install_root_dir = vim.fn.stdpath "data" .. "/mason"
local extension_path = install_root_dir .. "/packages/codelldb/extension/"
local codelldb_path = extension_path .. "adapter/codelldb"
local liblldb_path = extension_path .. "lldb/lib/liblldb.so"
local rt = require("rust-tools")

rt.setup({
        server = {
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                        on_attach(client, bufnr)
                        -- Hover actions
                        vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions,
                                { buffer = bufnr, desc = "LSP Hover Actions" })
                        -- Code action groups
                        vim.keymap.set("n", "<Leader>ca", rt.code_action_group.code_action_group,
                                { buffer = bufnr, desc = "LSP [C]ode [A]ction" })
                end,
                settings = {
                        ["rust-analyzer"] = {
                                checkOnSave = {
                                        command = "clippy",
                                },
                        },
                },
                dap = { adapter = false, },
        },

})

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
                ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                                cmp.select_next_item()
                        elseif luasnip.expand_or_locally_jumpable() then
                                luasnip.expand_or_jump()
                        else
                                fallback()
                        end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
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
                { name = "nvim_lsp" },
                { name = "luasnip" },
        },
}

-- Configure colorizer
vim.o.termguicolors = true -- Turn on full color terminal support
require("colorizer").setup()
