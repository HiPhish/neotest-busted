local conf = require 'neotest-busted._conf'
local lib  = require 'neotest-busted._lib'


---Collects the name of a node and all its ancestors in order from outer-most
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
				if lib.is_in_path(root, file_path) then
					return k, v
				end
			end
		end
	end
end

---Given a directory path return a table which maps a task name to a list of
---all -roots of that task below the path
---@param config table
---@param path   string
---@return table<string, string[]>
local function collect_tasks(config, path)
	local function below_path(root)
		return lib.is_in_path(path, root)
	end

	local result = {}
	for k, v in pairs(config) do
		local roots = vim.tbl_filter(below_path, v.ROOT or {})
		if #roots > 0 then
			result[k] = roots
		end
	end
	return result
end


---@param args neotest.RunArgs
---@return nil | neotest.RunSpec | neotest.RunSpec[]
return function(args)
	local tree = args.tree
	if not tree then return nil end
	local data = tree:data()
	local type = data.type

	local command = {vim.g.bustedprg or 'busted', '--output', 'json'}

	-- The user has selected a specific node inside the file
	if type == 'test' or type == 'namespace' then
		-- Names joined by space, from outer-most to inner-most
		local filter = table.concat(collect_node_names(tree, {}), ' ')
		-- Escape special characters
		filter = filter:gsub('%%', '%%%%'):gsub('%s', '%%s'):gsub('-', '%%-')

		vim.list_extend(command, {'--filter', filter})
	end

	if type == 'test' or type == 'namespace' or type == 'file' then
		local task = detect_task(conf.get(), data.path)
		if task then
			vim.list_extend(command, {'--run', task})
		end
		-- Specify the test file exactly to avoid ambiguity
		vim.list_extend(command, {'--', data.path})

		return {
			command = command,
		}
	elseif type == 'dir' then
		-- For each task collect its roots which are under the directory
		local tasks = collect_tasks(conf.get(), data.path)
		local result = {}
		-- For each task create a separate command with one or more roots
		for task, roots in pairs(tasks) do
			local cmd = vim.list_extend({}, command)
			vim.list_extend(cmd, {'--run', task, '--'})
			vim.list_extend(cmd, roots)
			table.insert(result, {command = cmd})
		end
		return result
	end
	error(string.format('Unknown node type: %s', type))
end
