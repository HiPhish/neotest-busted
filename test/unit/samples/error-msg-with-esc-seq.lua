-- Failure where the error message contains escape sequences


local types = require 'neotest.types'

local content = [[
	it('Always fails', function()
		local given = {a = 1, b = 3}
		local expected = {a = 1, b = 2}
		assert.are.same(expected, given)
	end)
]]


return function(tempfile)
	local output = {
		duration = 0.00027859500005434,
		pendings = {},
		successes = {},
		errors = {},
		failures = {
			{
				trace = {
					traceback = ('\nstack traceback:\n\t%s:4: in function <%s:1>\n'):format(tempfile, tempfile),
					linedefined = 1,
					currentline = 4,
					message = ('%s:4: Expected objects to be the same.\nPassed in:\n(table: 0x409a6508) {\n  [a] = 1\n \027[31m*\027[0m[b] = 3 }\nExpected:\n(table: 0x409a6568) {\n  [a] = 1\n \027[31m*\027[0m[b] = 2 }'):format(tempfile),
					lastlinedefined = 5,
					source = '@' .. tempfile,
					what = 'Lua',
					short_src = tempfile
				},
				element = {
					starttime = 1708852477.7823,
					starttick = 2248.999112388,
					trace = {
						traceback = ('\nstack traceback:\n\t:1: in main chunk\n'):format(tempfile),
						linedefined = 0,
						currentline = 1,
						message = 'Always fails',
						lastlinedefined = 6,
						source = '@' .. tempfile,
						what = 'main',
						short_src = tempfile
					},
					attributes = {},
					name = 'Always fails',
					descriptor = 'it'
				},
				message = ('%s:4: Expected objects to be the same.\nPassed in:\n(table: 0x409a6508) {\n  [a] = 1\n \027[31m*\027[0m[b] = 3 }\nExpected:\n(table: 0x409a6568) {\n  [a] = 1\n \027[31m*\027[0m[b] = 2 }'):format(tempfile),
				name = 'Always fails'
			}
		},
	}

	local expected_results = {
		[tempfile .. '::Always fails'] = {
			status = types.ResultStatus.failed,
			errors = {
				{
					line = 1,
					message = ('%s:4: Expected objects to be the same.\nPassed in:\n(table: 0x409a6508) {\n  [a] = 1\n *[b] = 3 }\nExpected:\n(table: 0x409a6568) {\n  [a] = 1\n *[b] = 2 }'):format(tempfile),
				}
			}
		}
	}

	local spec = {
		command = {'busted', '--output', 'json', '--', tempfile}
	}

	return content, output, spec, expected_results
end
