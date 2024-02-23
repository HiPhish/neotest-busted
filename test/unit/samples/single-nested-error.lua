-- Test file containing a single test nested inside a namespace which always
-- raises an error.


local types = require 'neotest.types'

local content = [[
describe('A test', function()
	it('Always raises an error', function()
		error('intentional error')
	end)
end)
]]

return function(tempfile)
	local output = {
		duration = 0.000204632000532,
		failures = {},
		pendings = {},
		successes = {},
		errors = {
			{
				isError = true,
				trace = {
					traceback = ('\nstack traceback:\n\t%s:2: in function <%s:2>\n'):format(tempfile, tempfile),
					linedefined = 2,
					currentline = 3,
					message = ('%s:3: intentional error'):format(tempfile),
					lastlinedefined = 4,
					source = '@' .. tempfile,
					what = 'Lua',
					short_src = tempfile
				},
				element = {
					starttime = 1708711446.9483,
					starttick = 19813.687664494,
					trace = {
						traceback = ('\nstack traceback:\n\t%s:2: in function <%s:2>\n'):format(tempfile, tempfile),
						linedefined = 1,
						currentline = 2,
						message = 'Always raises an error',
						lastlinedefined = 5,
						source = '@' .. tempfile,
						what = 'Lua',
						short_src = tempfile
					},
					attributes = {},
					name = 'Always raises an error',
					descriptor = 'it'
				},
				message = ('%s:3: intentional error'):format(tempfile),
				name = 'A test Always raises an error'
			}
		},
	}

	local expected_results = {
		[tempfile .. '::A test::Always raises an error'] = {
			status = types.ResultStatus.failed,
			errors = {
				{
					line = 2,
					message = ('%s:3: intentional error'):format(tempfile),
				}
			}
		}
	}

	local spec = {
		command = {'busted', '--output', 'json', '--', tempfile}
	}

	return content, output, spec, expected_results
end
