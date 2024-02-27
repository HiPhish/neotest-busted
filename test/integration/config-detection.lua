local adapter = require 'neotest-busted'
local conf = require 'neotest-busted._conf'

describe('The adapter', function()
	before_each(function()
		conf.set({})
	end)

	it('Finds the root directory of this plugin', function()
		local root = adapter.root('test/dummy-projects/empty-settings/')
		assert.is.equal('test/dummy-projects/empty-settings/', root)
	end)

	it('Loads the settings into the configuration as a side effect', function()
		adapter.root('test/dummy-projects/regular/')
		local expected = loadfile('test/dummy-projects/regular/.busted')()
		assert.are.same(expected, conf.get())
	end)

	it('Errors when the configuration is not a table', function()
		local expected = 'Busted configuration is of type string, but it needs to be table'
		local detect_root = function()
			adapter.root('test/dummy-projects/not-table-settings/')
		end
		assert.has_error(detect_root, expected)
	end)

	it('Skips configuration if config file is not trusted', function()
		adapter.root('test/dummy-projects/regular2/')
		assert.are.same(conf.default, conf.get())
	end)

	it('Uses the default when there is no configuration file', function()
		adapter.root('test/dummy-projects/no-settings/')
		assert.are.same(conf.default, conf.get())
	end)
end)
