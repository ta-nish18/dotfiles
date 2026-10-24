-- spaceをリーダーにする
vim.g.mapleader = " "

local keymap = vim.keymap

-- jkでインサートモードを抜ける
keymap.set("i", "jk", "<ESC>", { silent = true })

-- jkでビジュアルモードを抜ける
keymap.set("v", "jk", "<ESC>", { silent = true })

-- 検索ハイライトを消す(Space + h)
keymap.set("n", "<leader>h", ":nohlsearch<CR>")

-- 保存 (Space + w)
keymap.set("n", "<leader>w", ":w<CR>")

-- 終了 (Space + q)
keymap.set("n", "<leader>q", ":q<CR>")

-- ターミナルモードを抜ける (Esc)
keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ファイルの中身を全てコピーする Yank All (Space + ya)
keymap.set("n", "<leader>ya", ":%y+<CR>", { desc = "Yank All" })
