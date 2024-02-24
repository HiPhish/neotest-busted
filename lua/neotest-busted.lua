-- See also https://lunarmodules.github.io/busted/#usage
local lib  = require 'neotest.lib'
local conf = require 'neotest-busted._conf'

---Neotest adapter for the Busted test runner
local M = {
	name = 'Busted',
	is_test_file = require 'neotest-busted._is_test_file',
	build_spec = require 'neotest-busted._build_spec',
	results = require 'neotest-busted._results',
	filter_dir = require 'neotest-busted._filter_dir',
}

---The Tree-sitter query used to parse test files.
local query = [[
;;; Describe-block
(function_call
   name: (identifier) @_func_name (#eq? @_func_name "describe")
   arguments: (arguments
                (string
                  content: (string_content) @namespace.name)
                (function_definition))) @namespace.definition

;;; It-block
(function_call
   name: (identifier) @_func_name (#eq? @_func_name "it")
   arguments: (arguments
                (string
                  content: (string_content) @test.name)
                (function_definition))) @test.definition
]]

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function M.discover_positions(file_path)
	local opts = {
		nested_namespaces = true,
		require_namespaces = false,
	}
	return lib.treesitter.parse_positions(file_path, query, opts)
end

---Searches upwards from the current working directory for a file named
--`.busted`.  Sets the configuration as a side effect.
---@param path string
---@return string?
function M.root(path)
	local result = lib.files.match_root_pattern('.busted')(path)
	if not result then return end
	local conf_file = string.format('%s/.busted', result)
	if vim.fn.filereadable(conf_file) then
		local busted_conf = loadfile(conf_file)()
		local t = type(busted_conf)
		if t ~= 'table' then
			error(string.format('Busted configuration is of type %s, but it needs to be table', t))
		end
		conf.set(busted_conf)
	end
	return result
end

return M
