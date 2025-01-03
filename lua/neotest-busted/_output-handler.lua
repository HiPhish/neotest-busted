---This is a modified version of the standard JSON output handler from busted.
---The main difference is that this handler inserts an explicit separator
---before the JSON result output.  The reason is that busted writes both the
---standard output from tests and the result of running tests to standard
---output, potentially mixing the two on the same line.

local io_write = io.write
local io_flush = io.flush

local M = {}

---Prefix to mark the line containing test results as opposed to the standard
---output of the test
M.marker = '::NEOTEST_LINE::'

---Full path to this module so it can be referenced by Neovim.  We have no
---control over the working directory of the Neovim process, so the output
---handler has to know its own absolute file path.  Neovim can then require the
---handler as a module and get this information.
M.source = debug.getinfo(1).source:sub(2)

function M:__call(_options)
	local json = require('dkjson')
	local busted = require('busted')
	local handler = require('busted.outputHandlers.base')()

	handler.suiteEnd = function()
		local error_info = {
			pendings = handler.pendings,
			successes = handler.successes,
			failures = handler.failures,
			errors = handler.errors,
			duration = handler.getDuration(),
		}
		local ok, result = pcall(json.encode, error_info)

		io_write('\n' .. M.marker)

		if ok then
			io_write(result)
		else
			io_write('Failed to encode test results to json: ' .. result)
		end

		io_write('\n')
		io_flush()

		return nil, true
	end

	busted.subscribe({ 'suite', 'end' }, handler.suiteEnd)

	return handler
end

return setmetatable(M, M)
