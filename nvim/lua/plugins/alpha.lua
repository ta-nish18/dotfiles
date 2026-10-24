-- Neovimの起動画面をカスタマイズするための設定
return {
  {
    "goolord/alpha-nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "MaximilianLloyd/ascii.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      local art = require("ascii").art.text.neovim.sharp

      dashboard.section.header.val = art

      -- カスタムボタンの設定
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find File", ":Telescope find_files<CR>"),
        dashboard.button("r", "  Recent Files", ":Telescope oldfiles<CR>"),
        dashboard.button("g", "  Find Text", ":Telescope live_grep<CR>"),
        dashboard.button("c", "  Config", ":e $MYVIMRC<CR> | :cd %:p:h | split .<CR>"),
        dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }

      -- カスタムフッターの設定
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })

      alpha.setup(dashboard.config)
    end,
  },
}
