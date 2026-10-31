-- Python / MATLABの現在のファイルをフローティングターミナルで実行する
local function run_in_terminal(command)
  vim.cmd("write")
  vim.cmd("botright new")
  vim.fn.termopen(command)
  vim.cmd("startinsert")
end

local function python_command(file)
  local root = vim.fs.root(0, { "pyproject.toml", ".git" })
  local is_windows = vim.fn.has("win32") == 1
  local venv_bin = is_windows and "/.venv/Scripts/python.exe" or "/.venv/bin/python"
  local venv_python = root and (root .. venv_bin) or nil
  local system_python = is_windows and "python" or "python3"
  local python = venv_python and vim.fn.executable(venv_python) == 1 and venv_python or system_python
  return { python, file }
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(event)
    vim.keymap.set("n", "<leader>rr", function()
      run_in_terminal(python_command(vim.api.nvim_buf_get_name(event.buf)))
    end, { buffer = event.buf, desc = "Run Python file" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "matlab",
  callback = function(event)
    vim.keymap.set("n", "<leader>rr", function()
      local matlab = require("matlab").executable()
      if not matlab then
        vim.notify("MATLABが見つかりません。必要ならMATLAB_ROOTを設定してください。", vim.log.levels.ERROR)
        return
      end
      local file = vim.api.nvim_buf_get_name(event.buf)
      local matlab_file = file:gsub("'", "''")
      run_in_terminal({
        matlab,
        "-batch",
        ("run('%s')"):format(matlab_file),
      })
    end, { buffer = event.buf, desc = "Run MATLAB file" })
  end,
})
