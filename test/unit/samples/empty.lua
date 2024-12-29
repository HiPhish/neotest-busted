-- An empty test file.

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
    command = { 'busted', '--output', 'json', '--', tempfile },
  }

  return content, output, spec, expected_results
end
