-- インデントの可視化
return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = {
        char = "|",
        tab_char = "|",
      },
      scope = { enabled = false }, -- Treesitterと競合する可能性あるので一旦オフ
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "lazy",
        },
      },
    },
  },
}
