-- See also https://lunarmodules.github.io/busted/#usage
local lib = require 'neotest.lib'
local conf = require 'neotest-busted.conf'


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


---Collects the name of a node and all its ancestors in order from outer-mods
---down to the given node.
---@param node  neotest.Tree  Current Neotest node
---@param names string[]      Collected node names so far
---@return string[]  Final result of collecting names
local function collect_node_names(node, names)
	local data = node:data()
	if data.type ~= 'test' and data.type ~= 'namespace' then
		return names
	end
	table.insert(names, 1, data.name)
	local parent = node:parent()
	if not parent then return names end
	return collect_node_names(parent, names)
end

---Whether a given file path is contained within the given directory path.
---@param dir_path  string
---@param file_path string
---@return boolean
local function is_in_path(dir_path, file_path)
	-- normalize names
	dir_path = vim.fn.fnamemodify(dir_path, ':p')
	file_path = vim.fn.fnamemodify(file_path, ':p')

	return string.find(file_path, dir_path, 1, true) == 1
end

---Returns the name and configuration of the task the test file belongs to, if
---any.
---@param config    table   Busted configuration
---@param file_path string  Path to the test file
---@return string?, table?
local function detect_task(config, file_path)
	for k, v in pairs(config) do
		local roots = v.ROOT
		if roots and k ~= '_all' and k ~= 'default' then
			for _, root in ipairs(roots) do
				if is_in_path(root, file_path) then
					return k, v
				end
			end
		end
	end
end


---Neotest adapter for the Busted test runner
---@type neotest.Adapter
local M = {
	name = 'Busted',
	---Searches upwards from the current working directory for a file named
	--`.busted`.  Sets the configuration as a side effect.
	root = function(path)
		local result = lib.files.match_root_pattern('.busted')(path)
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
	end,
}

---Filter directories when searching for test files
---@async
---@param name     string  Name of directory
---@param rel_path string  Path to directory, relative to root
---@param root     string  Root directory of project
---@return boolean
local function filter_dir(name, rel_path, root)
	error 'TODO: not implemented yet'
end

---@async
---@param file_path string
---@return boolean
local function is_test_file(file_path)
	local directory = vim.fn.fnamemodify(file_path, ':h')
	local filename = vim.fn.fnamemodify(file_path, ':t:r')
	local extension = vim.fn.fnamemodify(file_path, ':e')

	-- Reject any file type that is not Lua; we might have to relax this rule
	-- in the future for Moonscript and Fennel
	if extension ~= 'lua' then return false end

	-- If a configuration has no root use this value
	local default_root = (conf.get()._all or {}).ROOT or ''
	for task, c in pairs(conf.get()) do
		if task ~= '_all' then
			local root = c.ROOT or default_root
			local pattern = c.pattern or '_spec'
			if vim.startswith(directory, root) and filename:find(pattern) then
				return true
			end
		end
	end
	return false
end

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
local function discover_positions(file_path)
	local opts = {
		nested_namespaces = true,
		require_namespaces = false,
	}
	return lib.treesitter.parse_positions(file_path, query, opts)
end

---@param args neotest.RunArgs
---@return nil | neotest.RunSpec | neotest.RunSpec[]
local function build_spec(args)
	if not args.tree then return nil end
	local data = args.tree:data()

	local command = {'busted'}

	-- The user has selected a specific node inside the file
	if data.type == 'test' or data.type == 'namespace' then
		-- Names joined by space, from outer-most to inner-most
		local filter = table.concat(collect_node_names(args.tree, {}), ' ')
		-- Escape special characters
		filter = filter:gsub('%%', '%%%%'):gsub('%s', '%%s'):gsub('-', '%%-')

		vim.list_extend(command, {'--filter', filter})
	end

	local task = detect_task(conf.get(), data.path)
	if task then
		vim.list_extend(command, {'--run', task})
	end

	-- Specify the test file exactly to avoid ambiguity
	vim.list_extend(command, {'--', data.path})

	return {
		command = command
	}
end

---@async
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
local function results(spec, result, tree)
	error 'TODO: not implemented yet'
end

M.filter_dir = filter_dir
M.is_test_file = is_test_file
M.discover_positions = discover_positions
M.build_spec = build_spec
M.results = results
return M
