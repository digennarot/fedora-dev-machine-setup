-- Colorscheme
local ok, _ = pcall(vim.cmd, "colorscheme github_dark_default")
if not ok then
    vim.cmd("colorscheme habamax") -- fallback
end

-- Statusline
local ok2, lualine = pcall(require, "lualine")
if ok2 then
    lualine.setup({
        options = { theme = "auto" },
    })
end

-- Buffer tabs
local ok3, bufferline = pcall(require, "bufferline")
if ok3 then
    bufferline.setup()
end

-- Dashboard
local ok4, alpha = pcall(require, "alpha")
if ok4 then
    local dashboard = require("alpha.themes.dashboard")
    dashboard.section.header.val = {
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗  ",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║  ",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║  ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║  ",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝  ",
    }
    dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file",    "<cmd>FzfLua files<CR>"),
        dashboard.button("r", "  Recent files", "<cmd>FzfLua oldfiles<CR>"),
        dashboard.button("e", "  Explorer",     "<cmd>Oil<CR>"),
        dashboard.button("g", "  Live grep",    "<cmd>FzfLua live_grep<CR>"),
        dashboard.button("q", "  Quit",         "<cmd>qa<CR>"),
    }
    alpha.setup(dashboard.opts)
end

-- Indentation guides
local ok5, ibl = pcall(require, "ibl")
if ok5 then
    ibl.setup({ indent = { char = "│" } })
end

-- Colour-code highlighting (#rrggbb etc.)
local ok6, colorizer = pcall(require, "colorizer")
if ok6 then
    colorizer.setup()
end

-- Background transparency
local ok7, transparent = pcall(require, "transparent")
if ok7 then
    transparent.setup()
end

-- Which-key (keybinding hints)
local ok8, which_key = pcall(require, "which-key")
if ok8 then
    which_key.setup({
        icons = {
            breadcrumb = "»",
            separator  = "→",
            group      = "+",
        },
    })
    which_key.add({
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>p", group = "Preview" },
    })
end
