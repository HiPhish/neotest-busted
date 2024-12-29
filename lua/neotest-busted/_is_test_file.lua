local conf = require('neotest-busted._conf')
local lib = require('neotest-busted._lib')

local fnamemodify = vim.fn.fnamemodify

---@async
---@param file_path string
---@return boolean
return function(file_path)
  local filename = fnamemodify(file_path, ':t:r')
  local extension = fnamemodify(file_path, ':e')

  -- Reject any file type that is not Lua; we might have to relax this rule
  -- in the future for Moonscript and Fennel
  if extension ~= 'lua' then
    return false
  end

  for _, c in pairs(conf.get()) do
    local roots = c.ROOT or { fnamemodify('.', ':p') }
    local pattern = c.pattern or '_spec'
    if roots and filename:find(pattern) then
      for _, root in ipairs(roots) do
        if lib.is_in_path(root, file_path) then
          return true
        end
      end
    end
  end

  local default = conf.get().default
  if
    default
    and not default.ROOTS
    and filename:find(default.pattern or '_spec')
  then
    return true
  end

  return false
end
