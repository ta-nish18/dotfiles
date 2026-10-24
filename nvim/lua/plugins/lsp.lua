-- LSPの設定
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Mason(インストーラー) の設定
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls",
          "lua_ls",
          "ts_ls",
          "pyright",
          "ruff",
          "matlab_ls",
          "texlab",
          "yamlls",
          "cssls",
        },
        automatic_enable = true,
      })

      -- nvim-cmpの補完機能をすべてのLanguage Serverへ伝える
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- Go言語の個別設定
      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            analyses = { unusedparams = true },
            staticcheck = true,
          },
        },
      })

      -- Luaの個別設定
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = { diagnostics = { globals = { "vim" } } },
        },
      })

      -- JS/TS用の設定
      vim.lsp.config("ts_ls", {})

      -- CSS用の設定
      vim.lsp.config("cssls", {
        settings = {
          css = { validate = true },
          scss = { validate = true },
          less = { validate = true },
        },
      })

      -- Python用の設定
      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              typeCheckingMode = "basic",
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      -- RuffはLintを担当し、型情報の表示はPyrightに任せる
      vim.lsp.config("ruff", {
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
        end,
      })

      -- yaml用の設定
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            -- スキーマの自動ダウンロードを有効化
            schemaStore = {
              enable = true,
              url = "https://www.schemastore.org/api/json/catalog.json",
            },
            -- フォーマットの設定
            format = {
              enable = true,
            },
            validate = true,
            completion = true,
            hover = true,
          },
        },
      })

      -- LaTeX用の設定
      vim.lsp.config("texlab", {})

      -- matlab用の設定
      local matlab_path = require("matlab").install_path()
      if matlab_path then
        vim.lsp.config("matlab_ls", {
          cmd = { "matlab-language-server", "--stdio" },
          filetypes = { "matlab" },
          settings = {
            MATLAB = {
              installPath = matlab_path,
              indexWorkspace = true,
              matlabConnectionTiming = "onStart",
              telemetry = false,
            },
          },
        })
      else
        -- MATLAB未導入端末では、.mファイルを開いてもエラーを出さない
        vim.lsp.enable("matlab_ls", false)
      end

      -- キーバインド設定
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          -- 定義ジャンプ(Go Definition) -> gd
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          -- 情報表示(Hover) -> K
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          -- リネーム(変数名変更) -> <Space>rn
          vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
          -- コードアクション(修正提案) -> <Space>ca
          vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, opts)
          -- 参照先一覧 -> gr
          vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, opts)
        end,
      })
    end,
  },
}
