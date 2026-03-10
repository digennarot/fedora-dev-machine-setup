-- nvim-autopairs — auto-close brackets, parens, quotes
local ok, autopairs = pcall(require, "nvim-autopairs")
if ok then
    autopairs.setup()
end

-- autolist.nvim — continue markdown / org lists automatically
local ok2, autolist = pcall(require, "autolist")
if ok2 then
    autolist.setup()
    vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>")
    vim.keymap.set("n", "o",    "o<cmd>AutolistNewBullet<cr>")
    vim.keymap.set("n", "O",    "O<cmd>AutolistNewBulletBefore<cr>")
end

-- render-markdown.nvim — render markdown in-buffer
local ok3, render_md = pcall(require, "render-markdown")
if ok3 then
    render_md.setup()
end

-- markdown-preview.nvim — live browser preview
local ok4 = pcall(require, "markdown-preview")
if ok4 then
    vim.g.mkdp_filetypes = { "markdown" }
    -- ensure the Node helper binary is built on first load
    vim.defer_fn(function()
        vim.cmd("call mkdp#util#install()")
    end, 1000)
end
