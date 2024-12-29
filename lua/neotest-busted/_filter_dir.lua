local conf = require('neotest-busted._conf')
local lib = require('neotest-busted._lib')

---@param task table  The task object
---@return string[] roots  The roots of this particular task
local function get_root(task)
  return task.ROOT
end

---Filter directories when searching for test files
---@async
---@param _name     string  Name of directory
---@param rel_path  string  Path to directory, relative to root
---@param _root     string  Root directory of project
---@return boolean
return function(_name, rel_path, _root)
  local roots = vim
    .iter(vim.tbl_values(vim.tbl_map(get_root, conf.get())))
    :flatten()
    :totable()
  if #roots == 0 then
    return true
  end
  for _, root in ipairs(roots) do
    if lib.is_in_path(rel_path, root) or lib.is_in_path(root, rel_path) then
      return true
    end
  end
  return false
end
