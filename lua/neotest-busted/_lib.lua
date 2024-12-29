---All the functions I don't want to write twice.
local M = {}

---Whether a given file path is contained within the given directory path.
---@param dir_path  string  Path of the directory which might contain the file
---@param file_path string  Path of the file
---@return boolean
function M.is_in_path(dir_path, file_path)
  -- normalize names
  dir_path = vim.fn.fnamemodify(dir_path, ':p')
  file_path = vim.fn.fnamemodify(file_path, ':p')

  return string.find(file_path, dir_path, 1, true) == 1
end

return M
