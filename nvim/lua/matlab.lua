local M = {}

function M.install_path()
  local configured = vim.env.MATLAB_ROOT
  if configured and vim.fn.isdirectory(configured) == 1 then
    return configured
  end

  local patterns = vim.fn.has("mac") == 1
      and { "/Applications/MATLAB_R*.app" }
    or { "/usr/local/MATLAB/R*", "/opt/MATLAB/R*" }
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

  local executable = install_path .. "/bin/matlab"
  return vim.fn.executable(executable) == 1 and executable or nil
end

return M
