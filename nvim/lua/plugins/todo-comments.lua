-- TODOのハイライト
return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "BufRead",
  opts = {},
  keys = {
    -- <Space>ft で、プロジェクト内のTODOをTelescopeで検索
    { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
  },
}
