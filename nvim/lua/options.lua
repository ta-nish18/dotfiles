local opt = vim.opt

opt.number = true         -- 行番号を表示
opt.relativenumber = true -- 相対行番号を表示
opt.cursorline = true     -- カーソル行をハイライト
opt.cursorcolumn = true   -- カーソル列をハイライト
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#444444", force = true })
  end,
})

opt.tabstop = 2        -- タブ文字が画面上で何文字に見えるか
opt.shiftwidth = 2     -- 自動インデントなどでずらす幅
opt.expandtab = true   -- tab -> space
opt.smartindent = true -- 改行した時、前の行に合わせて勝手に字下げする

opt.ignorecase = true  -- 検索で大文字小文字の区別なくす
opt.smartcase = true

opt.termguicolors = true                    -- 24bit color
opt.clipboard:append("unnamedplus")         -- クリップボード共有
opt.mouse = "a"                             -- マウス有効化

opt.encoding = "utf-8"                      -- 内部文字コード
opt.fileencoding = "utf-8"                  -- ファイルの文字コード

opt.foldmethod = "expr"                     -- 折りたたみ
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99                           -- 開始時は全て展開

-- Markdown は見出しを優先して折りたたみを作る（zaで安定して開閉）
_G.markdown_heading_foldexpr = function()
  local line = vim.fn.getline(vim.v.lnum)
  local hashes = line:match("^(#+)%s+")

  if hashes then
    return ">" .. #hashes
  end

  return "="
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.markdown_heading_foldexpr()"
  end,
})
