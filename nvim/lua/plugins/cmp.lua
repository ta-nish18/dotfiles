-- 入力中に補完を出す
return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSPからの候補
      "hrsh7th/cmp-buffer",   -- 開いているファイルからの候補
      "L3MON4D3/LuaSnip",     -- スニペットエンジン
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(),        -- Ctrl+k で上移動
          ["<C-j>"] = cmp.mapping.select_next_item(),        -- Ctrl+j で下移動
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enterで確定
          ["<C-Space>"] = cmp.mapping.complete(),            -- Ctrl+Spaceで補完を出す
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },
}
