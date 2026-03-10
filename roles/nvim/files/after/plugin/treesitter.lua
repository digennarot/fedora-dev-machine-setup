local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then return end

configs.setup({
    ensure_installed = {
        -- shell / config
        "bash", "lua", "vim", "vimdoc",
        -- data formats
        "json", "yaml", "toml", "xml",
        -- web
        "html", "css", "javascript", "typescript",
        -- documentation
        "markdown", "markdown_inline",
        -- languages used in this dev machine setup
        "python", "go", "ruby",
        -- infra
        "terraform", "dockerfile",
    },
    auto_install = false,
    highlight    = { enable = true },
    indent       = { enable = true },
})
