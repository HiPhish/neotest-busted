local adapter = require 'neotest-busted'
local conf = require 'neotest-busted.conf'

describe('The adapter', function()
	it('Errors when the configuration is not a table', function()
		pending 'TODO'
	end)

	it('Finds the root directory of this plugin', function()
		local root = adapter.root('.')
		assert.is.equal('.', root)
	end)
end)
