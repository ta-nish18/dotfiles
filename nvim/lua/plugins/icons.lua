-- mini.iconsの設定
return {
  {
    "echasnovski/mini.icons",
    version = false,
    config = function()
      require("mini.icons").setup()
      require("mini.icons").mock_nvim_web_devicons()
    end,
  },
}
