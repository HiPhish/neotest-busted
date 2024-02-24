local nio = require 'nio'
local adapter = require 'neotest-busted'
local split = vim.fn.split
local fnamemodify = vim.fn.fnamemodify


-- NOTE: We need a representation of the JSON output from running a test and
-- the Neotest tree of the test file.  The easiest way is to generate the data
-- and if necessary clean it up.
--
-- Write the content of a test to a Lua file, then run busted on it to produce
-- the JSON.  Convert the JSON to the Lua representation and paste the result
-- in here.  You might have to fix up the file names to match the imaginary
-- 'tempfile'.  Yes, it's annoying, but at least the test can run with actual
-- accurate sample data.


describe('Result from running busted', function()
	---Path to the file containing the test code.
	---@type string
	local testfile

	---@param sample string  Name of the sample file (without path or extension)
	---@return table<string, neotest.Result>, table<string, neotest.Result>
	local function compute_test_results(sample)
		local sample_file = string.format('test/unit/samples/%s.lua', sample)
		local content, output, spec, expected = loadfile(sample_file)()(testfile)

		---@type neotest.StrategyResult
		local strategy_result = {
			code = 0,
			output = vim.fn.tempname()
		}

		vim.fn.writefile(split(content, '\n'), testfile, 's')
		local tree = assert(nio.tests.with_async_context(adapter.discover_positions, testfile))

		-- We need to write the output to an actual file for the `results`
		-- function
		vim.fn.writefile({vim.json.encode(output)}, strategy_result.output, 's')

		local results = adapter.results(spec, strategy_result, tree)
		return expected, results
	end

	before_each(function()
		local tempdir = fnamemodify(vim.fn.tempname(), ':h')
		testfile = tempdir .. '/test/unit/dummy_spec.lua'
		-- Without intermediate directories writing the test file will fail
		vim.fn.mkdir(fnamemodify(testfile, ':h'), 'p', 448)  -- 448 = 0o700
	end)

	after_each(function()
		-- Delete temporary file
		if vim.fn.filereadable(testfile) ~= 0 then
			vim.fn.delete(testfile)
		end
	end)

	it('Is empty when there are no tests', function()
		local expected, results = compute_test_results('empty')
		assert.are.same(expected, results)
	end)

	it('Contains a success for a single test', function()
		local expected, results = compute_test_results('single-standalone-success')
		assert.are.same(expected, results)
	end)

	it('Contains a failure for a single failure', function()
		local expected, results = compute_test_results('single-standalone-failure')
		assert.are.same(expected, results)
	end)

	it('Contains a failure for a single error', function()
		local expected, results = compute_test_results('single-standalone-error')
		assert.are.same(expected, results)
	end)

	it('Contains a skip for a single pending test', function()
		local expected, results = compute_test_results('single-standalone-pending')
		assert.are.same(expected, results)
	end)

	it('Contains a success for a nested success', function()
		local expected, results = compute_test_results('single-nested-success')
		assert.are.same(expected, results)
	end)

	it('Contains a failure for a nested failure', function()
		local expected, results = compute_test_results('single-nested-failure')
		assert.are.same(expected, results)
	end)

	it('Contains a failure for a nested error', function()
		local expected, results = compute_test_results('single-nested-error')
		assert.are.same(expected, results)
	end)

	it('Contains a failure for a nested pending', function()
		local expected, results = compute_test_results('single-nested-pending')
		assert.are.same(expected, results)
	end)
end)
