-- Install the Lua parser because we will need it in most tests

local lua_parsers = vim.api.nvim_get_runtime_file('parser/lua.*', true)
if #lua_parsers == 0 then
  vim.cmd('silent TSInstallSync lua')
end
