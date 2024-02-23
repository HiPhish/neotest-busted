local types = require 'neotest.types'


---Decode the file under the given path to a suitable test output structure.
---@param path string  Path to file containing JSON output
---@return table output  Arbitrary JSON data from the output
local function decode_result_output(path)
	-- Assumption: the output will be all one line.  There might be other junk
	-- on subsequent lines and we don't want that.
	return vim.json.decode(vim.fn.readfile(path)[1])
end

---Convert a test failure entry to a result item.
---@param failure table  Entry in the test runner output
---@return string key, neotest.Result result  The node ID and the result item
local function failure_to_result(failure, map)
	local file = failure.trace.source:sub(2)
	local name = failure.name
	local key = map[file][name]
	local result = {
		status = types.ResultStatus.failed,
		errors = {
			{
				line = failure.trace.linedefined,
				message = failure.trace.message,
			}
		}
	}
	return key, result
end


---Builds up a mapping of test files and test names onto tree node IDs.  The
---indices of the outer table are file names, the indices of the inner tables
---are names of tests within the corresponding files, the values are node IDs.
---@param tree neotest.Tree
---@param acc table<string, table<string, string>>
---@return table<string, table<string, string>>
local function tree_to_map(tree, acc)
	local id = tree:data().id
	local start, stop = id:find('::', 1, true)
	local file, name
	if not start then
		file, name = id, ''
	else
		file = id:sub(1, start - 1)
		name = id:sub(stop + 1):gsub('::', ' ')
	end

	if not acc[file] then acc[file] = {} end
	acc[file][name] = id

	for _, child in ipairs(tree:children()) do
		tree_to_map(child, acc)
	end

	return acc
end

---@async
---@param _spec neotest.RunSpec
---@param run_result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
return function(_spec, run_result, tree)
	local ok, json = pcall(decode_result_output, run_result.output)
	if not ok then
		error(('Failed parsing file %s as JSON.\n%s'):format(run_result.output, json))
	end

	local map = tree_to_map(tree, {})
	local result = {}

	-- Handle the different types of output items
	for _, success in ipairs(json.successes) do
		local file = success.trace.source:sub(2)
		local name = success.name
		local key = map[file][name]
		result[key] = {status = types.ResultStatus.passed}
	end
	for _, failure in ipairs(json.failures) do
		local k, v = failure_to_result(failure, map)
		result[k] = v
	end
	for _, failure in ipairs(json.errors) do
		local k, v = failure_to_result(failure, map)
		result[k] = v
	end
	for _, pending in ipairs(json.pendings) do
		local file = pending.trace.source:sub(2)
		local name = pending.name
		local key = map[file][name]
		result[key] = {
			status = types.ResultStatus.skipped,
			short = pending.message,
		}
	end

	return result
end
