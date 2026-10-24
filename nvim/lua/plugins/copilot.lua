-- copilot有効化
return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        -- ファイルタイプごとの有効/無効設定
        filetypes = {
          yaml = true,
          markdown = true,
          help = false,
          gitcommit = true,
          ["."] = true,
        },
        -- 提案の設定
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<Tab>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>"
          },
        },
        panel = { enabled = false },
      })
    end,
  },
}
