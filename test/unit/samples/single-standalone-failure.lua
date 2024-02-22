-- Test file containing a single failing test not nested inside any namespaces.


local types = require 'neotest.types'

local content = [[
it('Always fails', function()
	assert.is_true(false)
end)
]]

return function(tempfile)
	local output = {
		errors = {},
		failures = {
			{
				trace = {
					traceback = string.format('\nstack traceback:\n\t%s:1: in main chunk\n', tempfile),
					linedefined = 1,
					currentline = 2,
					message = 'test/unit/derp_spec.lua:2: Expected objects to be the same.\nPassed in:\n(boolean) false\nExpected:\n(boolean) true',
					lastlinedefined = 3,
					source = '@' .. tempfile,
					what = 'Lua',
					short_src = tempfile
				},
				element = {
					starttime = 1708631151.6183,
					starttick = 15649.476211151,
					trace = {
						traceback = string.format('\nstack traceback:\n\t%s:1: in main chunk\n', tempfile),
						linedefined = 0,
						currentline = 1,
						message = 'Always fails',
						lastlinedefined = 4,
						source = '@' .. tempfile,
						what = 'main',
						short_src = tempfile
					},
					attributes = {},
					name = 'Always fails',
					descriptor = 'it'
				},
				message = 'test/unit/derp_spec.lua:2: Expected objects to be the same.\nPassed in:\n(boolean) false\nExpected:\n(boolean) true',
				name = 'Always fails'
			}
		},
		pendings = {},
		duration = 0.00017511099940748,
		successes = {}
	}

	local expected_results = {
		[tempfile .. '::Always fails'] = {
			status = types.ResultStatus.failed,
			errors = {
				{
					line = 1,
					message = 'test/unit/derp_spec.lua:2: Expected objects to be the same.\nPassed in:\n(boolean) false\nExpected:\n(boolean) true'
				}
			}
		}
	}

	local spec = {
		command = {'busted', '--output', 'json', '--', tempfile}
	}

	return content, output, spec, expected_results
end
