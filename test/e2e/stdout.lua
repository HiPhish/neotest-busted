-- NOTE: tests tests should be run from within Neovim to make sure the plugin
-- can handle text output from within a test.  Ideally this should be run as an
-- end-to-end test, but I cannot figure out how to write these because Neotest
-- runs everything asynchronously.

local output_handler = require 'neotest-busted._output-handler'

describe('Test which write to standard output', function()

	it('Has an explicit line break', function()
		print('Some text written to standard output\n')
		assert.is_true(true)
	end)

	it('Has no explicit line break', function()
		print('Some text written to standard output')
		assert.is_true(true)
	end)

	it('Contains the result marker from the output handler', function()
		print(string.format('%sThis could trip us up', output_handler.marker))
		assert.is_true(true)
	end)
end)
