-- Test file containing a single test which succeeds not nested inside any
-- namespaces.


local types = require 'neotest.types'
local output_handler = require 'neotest-busted._output-handler'.source

local content = [[
it('Always succeeds', function()
	assert.is_true(true)
end)
]]


return function(tempfile)
	local output = {
		duration = 0.00013610699897981,
		errors = {},
		failures = {},
		pendings = {},
		successes = {
			{
				trace = {
					traceback = string.format('\nstack traceback:\n\t%s:1: in main chunk\n', tempfile),
					linedefined = 0,
					currentline = 1,
					message = 'Always succeeds',
					lastlinedefined = 4,
					source = '@' .. tempfile,
					what = 'main',
					short_src = tempfile
				},
				element = {
					starttime = 1708631002.1747,
					starttick = 15500.032580799,
					duration = 2.6400000933791e-05,
					endtick = 15500.032607199,
					trace = {
						traceback = string.format('\nstack traceback:\n\t%s:1: in main chunk\n', tempfile),
						linedefined = 0,
						currentline = 1,
						message = 'Always succeeds',
						lastlinedefined = 4,
						source = '@' .. tempfile,
						what = 'main',
						short_src = tempfile
					},
					descriptor = 'it',
					name = 'Always succeeds',
					endtime = 1708631002.1747,
					attributes = {}
				},
				name = 'Always succeeds'
			}
		}
	}

	local expected_results = {
		[tempfile .. '::Always succeeds'] = {
			status = types.ResultStatus.passed
		}
	}

	local spec = {
		command = {'busted', '--output', output_handler, '--', tempfile}
	}

	return content, output, spec, expected_results
end
