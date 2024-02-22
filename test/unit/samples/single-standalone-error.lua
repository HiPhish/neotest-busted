-- Test file containing a single successful test not nested inside any
-- namespaces.


local types = require 'neotest.types'

local content = [[
it('Always raises an error', function()
	error('intentional error')
end)
]]


return function(tempfile)
	local output = {
		duration = 0.0001520170008007,
		failures = {},
		pendings = {},
		successes = {},
		errors = {
			{
				isError = true,
				trace = {
					traceback = string.format('\nstack traceback:\n\t%s:1: in main chunk\n', tempfile),
					linedefined = 1,
					currentline = 2,
					message = ('%s:2: intentional error'):format(tempfile),
					lastlinedefined = 3,
					source = '@' .. tempfile,
					what = 'Lua',
					short_src = tempfile
				},
				element = {
					starttime = 1708633822.2266,
					starttick = 18320.084462885,
					trace = {
						traceback = string.format('\nstack traceback:\n\t%s:1: in main chunk\n', tempfile),
						linedefined = 0,
						currentline = 1,
						message = 'Always raises an error',
						lastlinedefined = 4,
						source = '@' .. tempfile,
						what = 'main',
						short_src = tempfile
					},
					attributes = {},
					name = 'Always raises an error',
					descriptor = 'it'
				},
				message = ('%s:2: intentional error'):format(tempfile),
				name = 'Always raises an error'
			}
		},
	}

	local expected_results = {
		[tempfile .. '::Always raises an error'] = {
			status = types.ResultStatus.failed,
			errors = {
				{
					line = 1,
					message = ('%s:2: intentional error'):format(tempfile),
				}
			}
		}
	}

	local spec = {
		command = {'busted', '--output', 'json', '--', tempfile}
	}

	return content, output, spec, expected_results
end
