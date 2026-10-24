-- ターミナル統合
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 20,
      open_mapping = [[<C-@>]], -- Ctrl + @でターミナルを開く
      direction = "float",
      float_opts = {
        border = "curved",
      },
    },
  },
}
