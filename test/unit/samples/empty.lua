-- An empty test file.

local output_handler = require 'neotest-busted._output-handler'.source

local content = ''

local expected_results = {}

local output = {
	duration = 4.1288000147688e-05,
	errors = {},
	failures = {},
	pendings = {},
	successes = {},
}

return function(tempfile)
	local spec = {
		command = {'busted', '--output', output_handler, '--', tempfile}
	}

	return content, output, spec, expected_results
end
