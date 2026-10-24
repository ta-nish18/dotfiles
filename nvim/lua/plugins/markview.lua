return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    ft = "markdown",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
      "3rd/image.nvim",
    },
    config = function()
      -- ヘッダーのカスタムカラー設定
      local h_color = {
        h1 = { bg = "#5c2e2e", fg = "#ff9e9e" },
        h2 = { bg = "#5c472e", fg = "#ffcd9e" },
        h3 = { bg = "#4f5c2e", fg = "#eaff9e" },
        h4 = { bg = "#2e455c", fg = "#9edaff" },
        h5 = { bg = "#3e2e5c", fg = "#c29eff" },
        h6 = { bg = "#2e5c52", fg = "#9effec" },
      }

      for i = 1, 6 do
        local color = h_color["h" .. i]
        vim.api.nvim_set_hl(0, "MarkviewHeading" .. i, {
          bg = color.bg,
          fg = color.fg,
          bold = true,
        })
        vim.api.nvim_set_hl(0, "MarkviewHeading" .. i .. "Sign", {
          bg = color.bg,
          fg = color.fg,
        })
      end

      -- 引用ブロックのカスタムカラー設定
      local callout_colors = {
        note = { bg = "#2a3045", fg = "#3388cc" },    -- Note, Info
        ok = { bg = "#2a3b35", fg = "#4ea886" },      -- Success, Tip
        warn = { bg = "#3b3626", fg = "#d4b05a" },    -- Question, Warning
        error = { bg = "#3d2929", fg = "#d96c6c" },   -- Error, Danger
        special = { bg = "#2d3245", fg = "#c29eff" }, -- Important
        default = { bg = "#2f2f2f", fg = "#adadad" }, -- Default
      }

      local hl_map = {
        MarkviewBlockQuoteNote = callout_colors.note,
        MarkviewBlockQuoteOk = callout_colors.ok,
        MarkviewBlockQuoteWarn = callout_colors.warn,
        MarkviewBlockQuoteError = callout_colors.error,
        MarkviewBlockQuoteSpecial = callout_colors.special,
        MarkviewBlockQuoteDefault = callout_colors.default,
      }

      for group_name, color in pairs(hl_map) do
        vim.api.nvim_set_hl(0, group_name, {
          bg = color.bg,
          fg = color.fg,
        })
      end

      -- コードブロックのカスタムカラー設定
      local code_colors = {
        bg = "#2E3E47",
        info = "#7c6f64",
        inline_bg = "#32302f",
        inline_fg = "#d3869b",
      }

      vim.api.nvim_set_hl(0, "MarkviewCode", {
        bg = code_colors.bg,
      })
      vim.api.nvim_set_hl(0, "MarkviewCodeInfo", {
        bg = code_colors.bg,
        fg = code_colors.info,
        bold = true,
      })
      vim.api.nvim_set_hl(0, "MarkviewCodeInline", {
        bg = code_colors.inline_bg,
        fg = code_colors.inline_fg,
      })

      local presets = require("markview.presets")
      require("markview").setup({

        markdown = {
          enable = true,
          headings = presets.headings.glow, -- 背景色が光る
          tables = {
            enable = true,
            style = "simple",
          },
          block_quotes = {
            enable = true,
            wrap = true,

            default = {
              border = "▋",
              hl = "MarkviewBlockQuoteDefault"
            },

            ["ABSTRACT"] = {
              preview = "󱉫 Abstract",
              hl = "MarkviewBlockQuoteNote",

              title = true,
              icon = "󱉫",
            },
            ["SUMMARY"] = {
              hl = "MarkviewBlockQuoteNote",
              preview = "󱉫 Summary",

              title = true,
              icon = "󱉫",
            },
            ["TLDR"] = {
              hl = "MarkviewBlockQuoteNote",
              preview = "󱉫 Tldr",

              title = true,
              icon = "󱉫",
            },
            ["TODO"] = {
              hl = "MarkviewBlockQuoteNote",
              preview = " Todo",

              title = true,
              icon = "",
            },
            ["INFO"] = {
              hl = "MarkviewBlockQuoteNote",
              preview = " Info",

              custom_title = true,
              icon = "",
            },
            ["SUCCESS"] = {
              hl = "MarkviewBlockQuoteOk",
              preview = "󰗠 Success",

              title = true,
              icon = "󰗠",
            },
            ["CHECK"] = {
              hl = "MarkviewBlockQuoteOk",
              preview = "󰗠 Check",

              title = true,
              icon = "󰗠",
            },
            ["DONE"] = {
              hl = "MarkviewBlockQuoteOk",
              preview = "󰗠 Done",

              title = true,
              icon = "󰗠",
            },
            ["QUESTION"] = {
              hl = "MarkviewBlockQuoteWarn",
              preview = "󰋗 Question",

              title = true,
              icon = "󰋗",
            },
            ["HELP"] = {
              hl = "MarkviewBlockQuoteWarn",
              preview = "󰋗 Help",

              title = true,
              icon = "󰋗",
            },
            ["FAQ"] = {
              hl = "MarkviewBlockQuoteWarn",
              preview = "󰋗 Faq",

              title = true,
              icon = "󰋗",
            },
            ["FAILURE"] = {
              hl = "MarkviewBlockQuoteError",
              preview = "󰅙 Failure",

              title = true,
              icon = "󰅙",
            },
            ["FAIL"] = {
              hl = "MarkviewBlockQuoteError",
              preview = "󰅙 Fail",

              title = true,
              icon = "󰅙",
            },
            ["MISSING"] = {
              hl = "MarkviewBlockQuoteError",
              preview = "󰅙 Missing",

              title = true,
              icon = "󰅙",
            },
            ["DANGER"] = {
              hl = "MarkviewBlockQuoteError",
              preview = " Danger",

              title = true,
              icon = "",
            },
            ["ERROR"] = {
              hl = "MarkviewBlockQuoteError",
              preview = " Error",

              title = true,
              icon = "",
            },
            ["BUG"] = {
              hl = "MarkviewBlockQuoteError",
              preview = " Bug",

              title = true,
              icon = "",
            },
            ["EXAMPLE"] = {
              hl = "MarkviewBlockQuoteSpecial",
              preview = "󱖫 Example",

              title = true,
              icon = "󱖫",
            },
            ["QUOTE"] = {
              hl = "MarkviewBlockQuoteDefault",
              preview = " Quote",

              title = true,
              icon = "",
            },
            ["CITE"] = {
              hl = "MarkviewBlockQuoteDefault",
              preview = " Cite",

              title = true,
              icon = "",
            },
            ["HINT"] = {
              hl = "MarkviewBlockQuoteOk",
              preview = " Hint",

              title = true,
              icon = "",
            },
            ["ATTENTION"] = {
              hl = "MarkviewBlockQuoteWarn",
              preview = " Attention",

              title = true,
              icon = "",
            },
            ["NOTE"] = {
              hl = "MarkviewBlockQuoteNote",
              preview = "󰋽 Note",

              title = true,
              icon = "󰋽",
            },
            ["TIP"] = {
              hl = "MarkviewBlockQuoteOk",
              preview = " Tip",

              title = true,
              icon = "",
            },
            ["IMPORTANT"] = {
              hl = "MarkviewBlockQuoteSpecial",
              preview = " Important",

              title = true,
              icon = "",
            },
            ["WARNING"] = {
              hl = "MarkviewBlockQuoteWarn",
              preview = " Warning",

              title = true,
              icon = "",
            },
            ["CAUTION"] = {
              hl = "MarkviewBlockQuoteError",
              preview = "󰳦 Caution",

              title = true,
              icon = "󰳦",
            }
          },
          code_blocks = {
            enable = true,
            border_hl = "MarkviewCode",
            info_hl = "MarkviewCodeInfo",
            label_direction = "right",
            label_hl = nil,
            min_width = 60,
            pad_amount = 2,
            pad_char = " ",
            default = {
              block_hl = "MarkviewCode",
              pad_hl = "MarkviewCode"
            },
            ["diff"] = {
              block_hl = function(_, line)
                if line:match("^%+") then
                  return "MarkviewPalette4";
                elseif line:match("^%-") then
                  return "MarkviewPalette1";
                else
                  return "MarkviewCode";
                end
              end,
              pad_hl = "MarkviewCode"
            },
            style = "block",
            sign = true,
          },

        },

        latex = {
          enable = true, -- デフォルトで有効
          -- 数式部分のハイライト設定など
          hl = "@markup.math",
        },

      })
    end
  }
}
