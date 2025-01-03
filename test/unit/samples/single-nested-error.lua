-- Test file containing a single test nested inside a namespace which always
-- raises an error.

local output_handler = require 'neotest-busted._output-handler'.source

local types = require 'neotest.types'

local content = [[
describe('A test', function()
	it('Always raises an error', function()
		assert.is_true(true)
		assert.is_true(true)
		error('intentional error')
		assert.is_true(true)
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
				message = ('%s:5: intentional error'):format(tempfile),
				name = "A test Always raises an error",
				trace = {
					currentline = 5,
					lastlinedefined = 7,
					linedefined = 2,
					message = ('%s:5: intentional error'):format(tempfile),
					traceback = ('\nstack traceback:\n\t%s:5: in function <%s:2>\n'):format(tempfile, tempfile),
					source = '@' .. tempfile,
					short_src = tempfile,
					what = "Lua"
				},
				element = {
					attributes = {},
					descriptor = "it",
					name = "Always raises an error",
					starttick = 5698.810599464,
					starttime = 1709468193.4852,
					trace = {
						currentline = 2,
						lastlinedefined = 8,
						linedefined = 1,
						traceback = ('\nstack traceback:\n\t%s:2: in function <%s:1>\n'):format(tempfile, tempfile),
						message = "Always raises an error",
						source = '@' .. tempfile,
						short_src = tempfile,
						what = "Lua"
					}
				},
			},
		},
	}

	local expected_results = {
		[tempfile .. '::A test::Always raises an error'] = {
			status = types.ResultStatus.failed,
			errors = {
				{
					line = 4,
					message = ('%s:5: intentional error'):format(tempfile),
				}
			}
		}
	}

	local spec = {
		command = {'busted', '--output', output_handler, '--', tempfile}
	}

	return content, output, spec, expected_results
end
