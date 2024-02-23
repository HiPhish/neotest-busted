-- Test file containing a single test nested inside a namespace which is always
-- pending.


local types = require 'neotest.types'

local content = [[
describe('A test', function()
	it('Always is pending', function()
		pending('Always pending')
	end)
end)
]]

return function(tempfile)
	local output = {
		duration = 0.00019949499983341,
		errors = {},
		failures = {},
		successes = {},
		pendings = {
			{
				trace = {
					traceback = ('\nstack traceback:\n\t%s:3: in function <%s:2>\n'):format(tempfile, tempfile),
					linedefined = 2,
					currentline = 3,
					message = 'Always pending',
					lastlinedefined = 4,
					source = '@' .. tempfile,
					what = 'Lua',
					short_src = tempfile,
				},
				element = {
					starttime = 1708712248.8074,
					starttick = 20615.546751936,
					duration = 5.0325001211604e-05,
					endtick = 20615.546802261,
					trace = {
						traceback = ('\nstack traceback:\n\t%s:2: in function <%s:1>\n'):format(tempfile, tempfile),
						linedefined = 1,
						currentline = 2,
						message = 'Always is pending',
						lastlinedefined = 5,
						source = '@' .. tempfile,
						what = 'Lua',
						short_src = tempfile,
					},
					descriptor = 'it',
					name = 'Always is pending',
					endtime = 1708712248.8074,
					attributes = {}
				},
				message = ('%s:3: Always pending'):format(tempfile),
				name = 'A test Always is pending'
			}
		},
	}

	local expected_results = {
		[tempfile .. '::A test::Always is pending'] = {
			status = types.ResultStatus.skipped,
			short = ('%s:3: Always pending'):format(tempfile),
		}
	}

	local spec = {
		command = {'busted', '--output', 'json', '--', tempfile}
	}

	return content, output, spec, expected_results
end
