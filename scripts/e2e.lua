vim.cmd('edit .busted')
vim.secure.trust({
	action = 'allow',
	bufnr = 0,
})

local neotest = require'neotest'
local nb = require'lua.neotest-busted'

local function consumer(client)
	client.listeners.results = function(_, results, partial)
		if partial == false then
			local has_fails = false
			local outputs = {}
			for _, result in pairs(results) do
				has_fails = has_fails or result.status ~= 'passed'
				outputs[result.output]=true
			end
			if has_fails then
				vim.cmd('cq!')
			end
			for output, _ in pairs(outputs) do
				vim.iter(vim.fn.readfile(output)):each(function(line)
					io.stdout:write(line .. '\n')
				end)
			end
			vim.cmd('qa!')
		end
	end
end
neotest.setup({adapters = {nb}, consumers = {consumer}})
neotest.run.run('./test/e2e/')


