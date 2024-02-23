-- See also https://lunarmodules.github.io/busted/#usage
local types = require 'neotest.types'
local lib   = require 'neotest.lib'
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
	return true  -- 'TODO: not implemented yet'
end

---@async
---@param file_path string
---@return boolean
local function is_test_file(file_path)
	local filename = vim.fn.fnamemodify(file_path, ':t:r')
	local extension = vim.fn.fnamemodify(file_path, ':e')

	-- Reject any file type that is not Lua; we might have to relax this rule
	-- in the future for Moonscript and Fennel
	if extension ~= 'lua' then return false end

	for _, c in pairs(conf.get()) do
		local roots = c.ROOT
		local pattern = c.pattern or '_spec'
		if roots and filename:find(pattern) then
			for _, root in ipairs(roots) do
				if is_in_path(root, file_path) then
					return true
				end
			end
		end
	end

	local default = conf.get().default
	if default and not default.ROOTS and filename:find(default.pattern or '_spec') then
		return true
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

	local command = {vim.g.bustedprg or 'busted', '--output', 'json'}

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


---@param failure table  Entry in the test runner output
---@return string, neotest.Result
local function failure_to_result(failure, map)
	local file = failure.trace.source:sub(2)
	local name = failure.name
	local key = map[file][name]
	local result = {
		status = types.ResultStatus.failed,
		errors = {
			{
				line = failure.trace.linedefined,
				message = failure.trace.message,
			}
		}
	}
	return key, result
end


---Builds up a mapping of test files and test names onto tree node IDs.  The
---indices of the outer table are file names, the indices of the inner tables
---are names of tests within the corresponding files, the values are node IDs.
---@param tree neotest.Tree
---@param acc table<string, table<string, string>>
---@return table<string, table<string, string>>
local function tree_to_map(tree, acc)
	local id = tree:data().id
	local start, stop = id:find('::', 1, true)
	local file, name
	if not start then
		file, name = id, ''
	else
		file = id:sub(1, start - 1)
		name = id:sub(stop + 1):gsub('::', ' ')
	end

	if not acc[file] then acc[file] = {} end
	acc[file][name] = id

	for _, child in ipairs(tree:children()) do
		tree_to_map(child, acc)
	end

	return acc
end

---@param path string  Path to file containing JSON output
---@return table
local function decode_result_output(path)
	-- Assumption: the output will be all one line.  There might be other junk
	-- on subsequent lines and we don't want that.
	return vim.json.decode(vim.fn.readfile(path)[1])
end

---@async
---@param _spec neotest.RunSpec
---@param run_result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
local function results(_spec, run_result, tree)
	local ok, json = pcall(decode_result_output, run_result.output)
	if not ok then
		error(('Failed parsing file %s as JSON.\n%s'):format(run_result.output, json))
	end

	local map = tree_to_map(tree, {})
	local result = {}

	for _, success in ipairs(json.successes) do
		local file = success.trace.source:sub(2)
		local name = success.name
		local key = map[file][name]
		result[key] = {status = types.ResultStatus.passed}
	end
	for _, failure in ipairs(json.failures) do
		local k, v = failure_to_result(failure, map)
		result[k] = v
	end
	for _, failure in ipairs(json.errors) do
		local k, v = failure_to_result(failure, map)
		result[k] = v
	end
	for _, pending in ipairs(json.pendings) do
		local file = pending.trace.source:sub(2)
		local name = pending.name
		local key = map[file][name]
		result[key] = {
			status = types.ResultStatus.skipped,
			short = pending.message,
		}
	end
	return result
end

M.filter_dir = filter_dir
M.is_test_file = is_test_file
M.discover_positions = discover_positions
M.build_spec = build_spec
M.results = results
return M
