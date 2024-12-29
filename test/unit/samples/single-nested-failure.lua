-- Test file containing a single test nested inside a namespace which always
-- fails.

local types = require('neotest.types')

local content = [[
describe('A test', function()
	it('Always fails', function()
		assert.is_true(true)
		assert.is_true(true)
		assert.is_true(false)  -- Failure here
		assert.is_true(true)
	end)
end)
]]

return function(tempfile)
  local output = {
    duration = 0.00024077399939415,
    errors = {},
    pendings = {},
    successes = {},
    failures = {
      {
        message = ('%s:5: Expected objects to be the same.\nPassed in:\n(boolean) false\nExpected:\n(boolean) true'):format(
          tempfile
        ),
        name = 'A test Always fails',
        trace = {
          currentline = 5,
          lastlinedefined = 7,
          linedefined = 2,
          message = ('%s:5: Expected objects to be the same.\nPassed in:\n(boolean) false\nExpected:\n(boolean) true'):format(
            tempfile
          ),
          traceback = ('\nstack traceback:\n\t%s:5: in function <%s:2>\n'):format(
            tempfile,
            tempfile
          ),
          source = '@' .. tempfile,
          short_src = tempfile,
          what = 'Lua',
        },
        element = {
          attributes = {},
          descriptor = 'it',
          name = 'Always fails',
          starttick = 5388.418545148,
          starttime = 1709467883.0931,
          trace = {
            currentline = 2,
            lastlinedefined = 8,
            linedefined = 1,
            message = 'Always fails',
            traceback = ('\nstack traceback:\n\t%s:2: in function <%s:1>\n'):format(
              tempfile,
              tempfile
            ),
            source = '@' .. tempfile,
            short_src = tempfile,
            what = 'Lua',
          },
        },
      },
    },
  }

  local expected_results = {
    [tempfile .. '::A test::Always fails'] = {
      status = types.ResultStatus.failed,
      errors = {
        {
          line = 4,
          message = ('%s:5: Expected objects to be the same.\nPassed in:\n(boolean) false\nExpected:\n(boolean) true'):format(
            tempfile
          ),
        },
      },
    },
  }

  local spec = {
    command = { 'busted', '--output', 'json', '--', tempfile },
  }

  return content, output, spec, expected_results
end
