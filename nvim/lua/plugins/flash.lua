-- カーソル移動
return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      -- s を押してから、移動したい場所の文字を打つとそこに飛べる
      { "s", mode = { "n", "x", "o"}, function() require("flash").jump() end, desc = "Flash" },
    },
  },
}
