local adapter = require 'neotest-busted'
local conf = require 'neotest-busted._conf'

describe('The adapter', function()
	it('Finds the root directory of this plugin', function()
		local root = adapter.root('test/dummy-projects/empty-settings/')
		assert.is.equal('test/dummy-projects/empty-settings/', root)
	end)

	it('Loads the settings into the configuration as a side effect', function()
		adapter.root('test/dummy-projects/empty-settings/')
		assert.are.same({}, conf.get())
	end)

	it('Errors when the configuration is not a table', function()
		assert.has_error(function()
			adapter.root('test/dummy-projects/not-table-settings/')
		end)
	end)
end)
