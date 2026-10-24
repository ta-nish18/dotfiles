-- ファイルエクスプローラー
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "echasnovski/mini.icons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      -- <Space>e でツリーを開閉する
      { "<leader>e", ":Neotree toggle<CR>", desc = "Toggle Explorer" },
    },
    opts = {
      -- ウィンドウの設定
      window = {
        width = 35,
        position = "right",
        mapping_options = {
          noremap = true,
          nowait = true,
        },
      },

      -- 上部のタブバー
      source_selector = {
        winbar = true,
        statusline = false,
        sources = {
          { source = "filesystem", display_name = " 󰉓 Files " },
          { source = "buffers", display_name = " 󰈙 Bufs " },
          { source = "git_status", display_name = " 󰊢 Git " },
        },
      },

      -- ファイルシステム設定
      filesystem = {
        bind_to_cwd = false,           -- カレントディレクトリにバインドしない
        follow_current_file = {
          enabled = true,              -- カレントファイルを追従
        },
        use_libuv_file_watcher = true, -- ファイル変更を自動検知
        filtered_items = {
          visible = true,              -- 隠しファイルも設定
          hide_dotfiles = false,       -- ドットファイルを隠さない
          hide_gitignored = false,     -- git管理外ファイルを隠さない
        },
      },

      -- 見た目の設定
      default_component_configs = {
        container = {
          enable_character_fade = true,
        },
        indent = {
          indent_size = 2,
          padding = 1,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "", -- 閉じたフォルダ (Nerd Font)
          folder_open = "", -- 開いたフォルダ
          folder_empty = "󰜌", -- 空のフォルダ
          default = "*",
          highlight = "NeoTreeFileIcon",
        },
        modified = {
          symbol = "[+]",
          highlight = "NeoTreeModified",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = "NeoTreeFileName",
        },
        git_status = {
          symbols = {
            -- Change type
            added     = "✚", -- or "A", ""
            modified  = "", -- or "M", ""
            deleted   = "✖", -- or "D", ""
            renamed   = "󰁕", -- or "R", ""
            -- Status type
            untracked = "",
            ignored   = "",
            unstaged  = "󰄱",
            staged    = "",
            conflict  = "",
          },
        },
      },
    },
  },
}
