-- Test file containing a single pending test not nested inside any namespaces.

local output_handler = require 'neotest-busted._output-handler'.source

local types = require 'neotest.types'

local content = [[
it('Always is pending', function()
	pending('Always pending')
end)
]]


return function(tempfile)
	local output = {
		duration = 0.0001631470004213,
		successes = {},
		errors = {},
		failures = {},
		pendings = {
			{
				trace = {
					traceback = ('\nstack traceback:\n\t%s:2: in function <%s:1>\n'):format(tempfile, tempfile),
					linedefined = 1,
					currentline = 2,
					message = 'Always pending',
					lastlinedefined = 3,
					source = '@' .. tempfile,
					what = 'Lua',
					short_src = tempfile
				},
				element = {
					starttime = 1708634905.5545,
					starttick = 19403.412353386,
					duration = 5.7639001170173e-05,
					endtick = 19403.412411025,
					trace = {
						traceback = ('\nstack traceback:\n\t%s:1: in main chunk\n'):format(tempfile),
						linedefined = 0,
						currentline = 1,
						message = 'Always is pending',
						lastlinedefined = 4,
						source = '@' .. tempfile,
						what = 'main',
						short_src = tempfile
					},
					descriptor = 'it',
					name = 'Always is pending',
					endtime = 1708634905.5545,
					attributes = {}
				},
				message = ('%s:2: Always pending'):format(tempfile),
				name = 'Always is pending'
			}
		}
	}

	local expected_results = {
		[tempfile .. '::Always is pending'] = {
			status = types.ResultStatus.skipped,
			short = ('%s:2: Always pending'):format(tempfile),
		}
	}

	local spec = {
		command = {'busted', '--output', output_handler, '--', tempfile}
	}

	return content, output, spec, expected_results
end
