-- A parent `before_each` throws an error

local output_handler = require 'neotest-busted._output-handler'.source

local types = require 'neotest.types'

local content = [[
describe('Arithmetic', function()
	before_each(function()
		error('Intentional error')
	end)

	describe('Additive', function()
		it('Adds two numbers', function()
			assert.are.equal(5, 2 + 3)
		end)
	end)
end)
]]

return function(tempfile)
	local output = {
		errors = {
			{
				isError = true,
				trace = {
					traceback = ('\nstack traceback:\n\t%s:3: in function <%s:2>\n'):format(tempfile, tempfile),
					linedefined = 2,
					currentline = 3,
					message = ('%s:3: Intentional error'):format(tempfile),
					lastlinedefined = 4,
					source = '@' .. tempfile,
					what = 'Lua',
					short_src = tempfile,
				},
				element = {
					attributes = {
						envmode = 'unwrap'
					},
					descriptor = 'before_each',
					trace = {
						traceback = ('\nstack traceback:\n\t%s:2: in function <%s:1>\n'):format(tempfile, tempfile),
						linedefined = 1,
						currentline = 2,
						message = 'nil',
						lastlinedefined = 11,
						source = '@' .. tempfile,
						what = 'Lua',
						short_src = tempfile,
					}
				},
				message = ('%s:3: Intentional error'):format(tempfile),
				name = 'Arithmetic before_each'
			}
		},
		failures = {},
		pendings = {},
		duration = 0.00026919700007966,
		successes = {}
	}

	local expected_results = {
		[tempfile .. '::Arithmetic::before_each'] = {
			status = types.ResultStatus.failed,
			errors = {
				{
					line = 2,
					message = ('%s:3: Intentional error'):format(tempfile)
				}
			}
		}
	}

	local spec = {
		command = {'busted', '--output', output_handler, '--filter', 'Arithmetic%sAdditive%sAdds%stwo%snumbers', '--', tempfile}
	}

	return content, output, spec, expected_results, {1, 2}
end

