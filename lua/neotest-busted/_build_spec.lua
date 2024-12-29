local conf = require('neotest-busted._conf')
local lib = require('neotest-busted._lib')

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
  if not parent then
    return names
  end
  return collect_node_names(parent, names)
end

---@param args neotest.RunArgs
---@return nil | neotest.RunSpec | neotest.RunSpec[]
return function(args)
  local tree = args.tree
  if not tree then
    return nil
  end
  local data = tree:data()
  local type = data.type

  local command = vim
    .iter({
      vim.g.bustedprg or 'busted',
      '--output',
      'json',
    })
    :flatten()
    :totable()

  -- The user has selected a specific node inside the file
  if type == 'test' or type == 'namespace' then
    -- Names joined by space, from outer-most to inner-most
    local filter = table.concat(collect_node_names(tree, {}), ' ')
    -- Escape special characters
    filter = filter:gsub('%%', '%%%%'):gsub('%s', '%%s'):gsub('-', '%%-')

    vim.list_extend(command, { '--filter', filter })
  end

  local _, _, bustedrc = conf.get()
  vim.list_extend(command, { '--config-file', bustedrc, data.path })

  return {
    command = command,
  }
end
