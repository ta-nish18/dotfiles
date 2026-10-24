-- Gitの変更箇所の可視化
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      -- 行番号の横に表示する記号
      signs = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      current_line_blame = true, -- カーソル行の変更履歴を表示
    },
  },
}
