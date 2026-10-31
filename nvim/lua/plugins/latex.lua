return {
  {
    "lervag/vimtex",
    tag = "v2.17",
    lazy = false,
    init = function()
      -- WindowsではVimTeXの既定動作でSumatraPDFが使われる
      if vim.fn.has("mac") == 1 then
        vim.g.vimtex_view_method = "skim"
      end
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_compiler_latexmk = {
        continuous = 1,
        callback = 1,
        options = {
          "-pdf",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function(event)
          local opts = { buffer = event.buf, silent = true }
          vim.keymap.set("n", "<leader>lc", "<cmd>VimtexCompile<CR>",
            vim.tbl_extend("force", opts, { desc = "LaTeX compile/watch" }))
          vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<CR>",
            vim.tbl_extend("force", opts, { desc = "LaTeX view PDF" }))
          vim.keymap.set("n", "<leader>ls", "<cmd>VimtexStop<CR>",
            vim.tbl_extend("force", opts, { desc = "LaTeX stop compiler" }))
          vim.keymap.set("n", "<leader>le", "<cmd>VimtexErrors<CR>",
            vim.tbl_extend("force", opts, { desc = "LaTeX errors" }))
        end,
      })
    end,
  },
}
