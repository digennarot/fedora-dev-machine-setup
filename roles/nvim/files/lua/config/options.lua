local opt = vim.opt

-- global statusline
opt.laststatus = 3

-- fat cursor (block in all modes)
opt.guicursor = ""

-- disable redundant mode message in cmdline
opt.showmode = false

-- enable system clipboard
opt.clipboard = "unnamedplus"

-- highlight current line
opt.cursorline = true

-- keep context lines above/below cursor
opt.scrolloff = 8

-- indenting (2-space soft tabs)
opt.expandtab    = true
opt.shiftwidth   = 2
opt.smartindent  = true
opt.tabstop      = 2
opt.softtabstop  = 2

-- clean empty-line gutter character
opt.fillchars = { eob = " " }

-- smart case-insensitive search
opt.ignorecase = true
opt.smartcase  = true

-- disable mouse
opt.mouse = ""

-- line numbers
opt.number         = true
opt.relativenumber = true
opt.numberwidth    = 2
opt.ruler          = false

-- do not highlight all search results
opt.hlsearch = false

-- no line wrapping
opt.wrap = false

-- always show sign column (avoids layout shift)
opt.signcolumn = "yes"

-- open splits to the right and below
opt.splitbelow = true
opt.splitright = true

-- true-colour support
opt.termguicolors = true

-- persistent undo across sessions
opt.undofile = true

-- faster swap/gitsigns updates
opt.updatetime = 250
