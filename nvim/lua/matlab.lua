local M = {}

function M.install_path()
  local configured = vim.env.MATLAB_ROOT
  if configured and vim.fn.isdirectory(configured) == 1 then
    return configured
  end

  local patterns
  if vim.fn.has("mac") == 1 then
    patterns = { "/Applications/MATLAB_R*.app" }
  elseif vim.fn.has("win32") == 1 then
    patterns = { "C:/Program Files/MATLAB/R*" }
  else
    patterns = { "/usr/local/MATLAB/R*", "/opt/MATLAB/R*" }
  end
  local candidates = {}

  for _, pattern in ipairs(patterns) do
    vim.list_extend(candidates, vim.fn.glob(pattern, false, true))
  end

  table.sort(candidates)
  return candidates[#candidates]
end

function M.executable()
  local install_path = M.install_path()
  if not install_path then
    return nil
  end

  local executable = install_path .. (vim.fn.has("win32") == 1 and "/bin/matlab.exe" or "/bin/matlab")
  return vim.fn.executable(executable) == 1 and executable or nil
end

return M
