-- Kanagawaのインストールと設定
return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        compile = true,
        undercurl = true,
        commandStyle = { italic = true },
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        transparent = true,
      })
      vim.cmd("colorscheme kanagawa")
    end,
  },
}
