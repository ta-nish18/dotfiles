-- ターミナル統合
local is_windows = vim.fn.has("win32") == 1

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 20,
      -- Ctrl + @でターミナルを開く(Windowsでは<C-Space>として届く場合がある)
      open_mapping = is_windows and { [[<C-@>]], [[<C-Space>]] } or [[<C-@>]],
      shell = is_windows and "pwsh" or nil,
      direction = "float",
      float_opts = {
        border = "curved",
      },
    },
  },
}
