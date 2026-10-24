-- Formatの設定
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        -- Go言語: goimportsとgofmtを実行
        go = { "goimports", "gofmt" },
        -- Lua: styluaを実行
        lua = { "stylua" },
        -- JS/TS/React系に prettier を適用
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        -- Python: Ruffで安全な自動修正と整形を順番に実行
        python = { "ruff_fix", "ruff_format" },
      },
      -- 保存時に自動整形
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    },
  },
}
