local adapter = require 'neotest-busted'

describe('Filtering of directories', function()
	local root
	before_each(function()
		root = adapter.root('test/dummy-projects/regular/')
	end)

	it('Accepts the source code directory', function()
		pending()
		local result = adapter.filter_dir('src', '', root)
		assert.is_true(result)
	end)

	it('Rejects the data directory', function()
		pending()
		local result = adapter.filter_dir('data', '', root)
		assert.is_false(result)
	end)
end)
