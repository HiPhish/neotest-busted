-- Test file containing a single test nested inside a namespace which always
-- succeeds.

local output_handler = require 'neotest-busted._output-handler'.source

local types = require 'neotest.types'

local content = [[
describe('A test', function()
	it('Always succeeds', function()
		assert.is_true(true)
	end)
end)
]]

return function(tempfile)
	local output = {
		duration = 0.00019949499983341,
		errors = {},
		failures = {},
		pendings = {},
		successes = {
			{
				trace = {
					traceback = ('\nstack traceback:\n\t%s:2: in function <%s:1>\n'):format(tempfile, tempfile),
					linedefined = 1,
					currentline = 2,
					message = 'Always succeeds',
					lastlinedefined = 5,
					source = '@' .. tempfile,
					what = 'Lua',
					short_src = tempfile
				},
				element = {
					starttime = 1708692559.646,
					starttick = 9291.888789039,
					duration = 1.9897001038771e-05,
					endtick = 9291.888808936,
					trace = {
						traceback = ('\nstack traceback:\n\t%s:2: in function <%s:1>\n'):format(tempfile, tempfile),
						linedefined = 1,
						currentline = 2,
						message = 'Always succeeds',
						lastlinedefined = 5,
						source = '@' .. tempfile,
						what = 'Lua',
						short_src = tempfile,
					},
					descriptor = 'it',
					name = 'Always succeeds',
					endtime = 1708692559.646,
					attributes = {}
				},
				name = 'A test Always succeeds'
			}
		}
	}

	local expected_results = {
		[tempfile .. '::A test::Always succeeds'] = {
			status = types.ResultStatus.passed
		}
	}

	local spec = {
		command = {'busted', '--output', output_handler, '--', tempfile}
	}

	return content, output, spec, expected_results
end
