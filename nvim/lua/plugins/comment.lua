-- gccと打つとその行はコメントアウト
return {
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("Comment").setup()
      -- Ctrl + / でコメントアウト
      vim.keymap.set("n", "<C-_>", "gcc", { remap = true, desc = "Toggle Comment Line" })
      vim.keymap.set("n", "<C-/>", "gcc", { remap = true, desc = "Toggle Comment Line" })

      vim.keymap.set("v", "<C-_>", "gc", { remap = true, desc = "Toggle Comment Selection" })
      vim.keymap.set("v", "<C-/>", "gc", { remap = true, desc = "Toggle Comment Selection" })
    end,
  },
}
