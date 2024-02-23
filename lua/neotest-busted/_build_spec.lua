local conf = require 'neotest-busted._conf'
local lib  = require 'neotest-busted._lib'


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


---@param args neotest.RunArgs
---@return nil | neotest.RunSpec | neotest.RunSpec[]
return function(args)
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
