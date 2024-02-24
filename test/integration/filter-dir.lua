local adapter = require 'neotest-busted'
local conf    = require 'neotest-busted._conf'

describe('Filtering of directories', function()
	local root

	before_each(function()
		root = adapter.root('.')
		conf.set {
			_all = {},
			default = {},
			unit = {
				ROOT = {'test/unit', 'test/simple'}
			},
			integration = {
				ROOT = {'test/integration'}
			}
		}
	end)

	it('Rejects the data directory', function()
		local result = adapter.filter_dir('data', 'data', root)
		assert.is_false(result)
	end)

	it('Accepts the unit test directory', function()
		local result = adapter.filter_dir('unit', 'test/unit', root)
		assert.is_true(result)
	end)


	it('Accepts the unit test subdirectory directory', function()
		local result = adapter.filter_dir('foo', 'test/unit/foo', root)
		assert.is_true(result)
	end)

	it('Accepts the unit test parent directory directory', function()
		local result = adapter.filter_dir('test', 'test', root)
		assert.is_true(result)
	end)
end)
