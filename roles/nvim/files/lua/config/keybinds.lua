vim.g.mapleader = " "

local map = vim.keymap.set

-- General
map("n", "<leader>a", "ggVG",  { desc = "Select all" })
map("v", "<",         "<gv",   { desc = "Indent left and keep selection" })
map("v", ">",         ">gv",   { desc = "Indent right and keep selection" })

-- Alpha dashboard
map("n", "<leader>m", "<cmd>Alpha<CR>", { desc = "Menu / dashboard" })

-- Tabs
map("n", "<leader>t", "<cmd>tabnew<CR>",   { desc = "New tab" })
map("n", "<leader>x", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>j", "<cmd>tabprev<CR>",  { desc = "Previous tab" })
map("n", "<leader>k", "<cmd>tabnext<CR>",  { desc = "Next tab" })

-- Buffers
map("n", "<Tab>",     "<cmd>bnext<CR>",    { desc = "Next buffer" })
map("n", "<S-Tab>",   "<cmd>bprev<CR>",    { desc = "Previous buffer" })
map("n", "<leader>q", "<cmd>bdelete<CR>",  { desc = "Close buffer" })

-- Splits
map("n", "<leader>v", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>s", "<cmd>split<CR>",  { desc = "Horizontal split" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<CR>", { desc = "Resize split left" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Resize split right" })
map("n", "<C-Up>",    "<cmd>resize +2<CR>",           { desc = "Resize split up" })
map("n", "<C-Down>",  "<cmd>resize -2<CR>",           { desc = "Resize split down" })

-- File explorer (oil.nvim)
map("n", "<leader>e", "<cmd>Oil<CR>", { desc = "File explorer" })

-- Fuzzy finding (fzf-lua)
map("n", "<leader>ff", "<cmd>FzfLua files<CR>",                            { desc = "Find files" })
map("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>",                        { desc = "Live grep" })
map("n", "<leader>fh", "<cmd>FzfLua help_tags<CR>",                        { desc = "Help tags" })
map("n", "<leader>fr", "<cmd>FzfLua oldfiles<CR>",                         { desc = "Recent files" })
map("n", "<leader>fc", "<cmd>FzfLua files cwd=~/.config/nvim<CR>",         { desc = "Config files" })

-- Git (vim-fugitive)
map("n", "<leader>gg", "<cmd>Git<CR>",        { desc = "Git status" })
map("n", "<leader>gc", "<cmd>Git branch<CR>", { desc = "Git branches" })

-- Markdown
map("n", "<leader>pp", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Markdown preview toggle" })
map("n", "<leader>pf", "<cmd>Prettier<CR>",              { desc = "Format with Prettier" })
