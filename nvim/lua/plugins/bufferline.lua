-- 開いているファイルをタブで表示するプラグイン
return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",

    keys = {
      -- <Shift>+ l: 次のタブへ移動
      { "<S-l>",      "<cmd>BufferLineCycleNext<cr>",   desc = "Next buffer" },
      -- <Shift>+ h: 前のタブへ移動
      { "<S-h>",      "<cmd>BufferLineCyclePrev<cr>",   desc = "Previous buffer" },
      -- <Space>+ db: タブを閉じる
      { "<leader>db", "<cmd>bdelete<cr>",               desc = "Delete buffer" },
      -- <Space>+ bo: 今のタブ以外の全てのタブを閉じる
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
      -- <Space>+ bp: タブをピン留めする
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>",   desc = "Toggle Pin" },
    },

    opts = {
      options = {
        mode = "buffers", -- タブにバッファを表示
        separator_style = "slant",
        always_show_bufferline = true,
        show_buffer_close_icons = false,
        show_close_icon = false,

        -- アイコン設定
        indicator = {
          style = "underline",
        },

        -- ファイルの状態を表示
        diagnostics = "nvim_lsp", -- エラーがある場合に表示

        -- オフセット
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },
}
