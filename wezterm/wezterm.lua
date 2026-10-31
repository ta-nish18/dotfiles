-- Windows用ターミナル設定。ghostty/ の設定に相当する。
local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

config.default_prog = { "pwsh.exe", "-NoLogo" }

-- テーマ設定
config.color_scheme = "Dracula"

-- フォント
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 12
config.adjust_window_size_when_changing_font_size = false

-- ブロックカーソルに変更 & 点滅無効
config.default_cursor_style = "SteadyBlock"

-- タイトルバー削除(枠でのサイズ変更は残す)
config.window_decorations = "RESIZE"

-- パディング
config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }

-- 背景透過度の設定
config.window_background_opacity = 0.8

-- Win + H/J/K/LはWindowsに予約されているため、Ghosttyのsuperの代わりにAltを使う
config.keys = {
  -- ペインの作成
  { key = "d", mods = "ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "ALT|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- ペインの移動
  { key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
  { key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
  { key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
  { key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },

  -- ペインのサイズ
  { key = "h", mods = "ALT|CTRL", action = act.AdjustPaneSize({ "Left", 20 }) },
  { key = "l", mods = "ALT|CTRL", action = act.AdjustPaneSize({ "Right", 20 }) },
  { key = "k", mods = "ALT|CTRL", action = act.AdjustPaneSize({ "Up", 20 }) },
  { key = "j", mods = "ALT|CTRL", action = act.AdjustPaneSize({ "Down", 20 }) },
}

return config
