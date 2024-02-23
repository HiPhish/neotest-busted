-- Test file containing a single test nested inside a namespace which always
-- fails.


local types = require 'neotest.types'

local content = [[
describe('A test', function()
	it('Always fails', function()
		assert.is_true(false)
	end)
end)
]]

return function(tempfile)
	local output = {
		duration = 0.00024077399939415,
		errors = {},
		pendings = {},
		successes = {},
		failures = {
			{
				trace = {
					traceback = ('\nstack traceback:\n\t%s:2: in function <%s:2>\n'):format(tempfile, tempfile),
					linedefined = 2,
					currentline = 3,
					message = ('%s:3: Expected objects to be the same.\nPassed in:\n(boolean) false\nExpected:\n(boolean) true'):format(tempfile),
					lastlinedefined = 4,
					source = '@' .. tempfile,
					what = 'Lua',
					short_src = tempfile
				},
				element = {
					starttime = 1708700722.7039,
					starttick = 15894.505587689,
					trace = {
						traceback = ('\nstack traceback:\n\t%s:2: in function <%s:1>\n'):format(tempfile, tempfile),
						linedefined = 1,
						currentline = 2,
						message = 'Always fails',
						lastlinedefined = 5,
						source = '@' .. tempfile,
						what = 'Lua',
						short_src = tempfile
					},
					attributes = {},
					name = 'Always fails',
					descriptor = 'it'
				},
				message = 'test/unit/dummy_spec.lua:3: Expected objects to be the same.\nPassed in:\n(boolean) false\nExpected:\n(boolean) true',
				name = 'A test Always fails'
			}
		},
	}

	local expected_results = {
		[tempfile .. '::A test::Always fails'] = {
			status = types.ResultStatus.failed,
			errors = {
				{
					line = 2,
					message = ('%s:3: Expected objects to be the same.\nPassed in:\n(boolean) false\nExpected:\n(boolean) true'):format(tempfile),
				}
			}
		}
	}

	local spec = {
		command = {'busted', '--output', 'json', '--', tempfile}
	}

	return content, output, spec, expected_results
end
