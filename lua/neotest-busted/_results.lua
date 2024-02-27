local types = require 'neotest.types'
local writefile = vim.fn.writefile


---Decode the file under the given path to a suitable test output structure.
---
---As a side effect the contents of the output file are overwritten with a
---human-readable representation of the output.  The content of the output file
---will be displayed in the Neotest UI, so we want it to be pleasant to read.
---@param path string  Path to file containing JSON output
---@return table output  Arbitrary JSON data from the output
local function decode_result_output(path)
	-- Assumption: the output will be all one line.  There might be other junk
	-- on subsequent lines and we don't want that.
	local result = vim.json.decode(vim.fn.readfile(path)[1])

	-- Write a human-readable representation of the test result to the output
	-- file. The output file contains JSON which we convert into regular text.
	-- The original contents will be overwritten.
	--
	-- See also:
	-- https://github.com/lunarmodules/busted/blob/master/busted/outputHandlers/plainTerminal.lua

	local success  = result.successes
	local failures = result.failures
	local errors   = result.errors
	local pendings = result.pendings

	local icons = ('%s%s%s%s'):format(
		string.rep('+', #success),
		string.rep('-', #failures),
		string.rep('*', #errors),
		string.rep('.', #pendings)
	)
	local summary = ('%d successes / %d failures / %d errors / %d pending : %d seconds\n')
		:format(#success, #failures, #errors, #pendings, result.duration)
	writefile({icons, summary, ''}, path, 'S')

	for _, pending in ipairs(pendings) do
		local content = {
			('Pending -> %s @ %d'):format(pending.trace.short_src, pending.trace.currentline),
			pending.name,
		}
		writefile(content, path, 'Sa')
		writefile(vim.split(pending.message, '\n'), path, 'Sa')
		writefile({''}, path, 'Sa')
	end

	for _, failure in ipairs(failures) do
		local content = {
			('Failure -> %s @ %d'):format(failure.element.trace.short_src, failure.element.trace.currentline),
			failure.name,
		}
		writefile(content, path, 'Sa')
		writefile(vim.split(failure.message, '\n'), path, 'Sa')
		writefile({''}, path, 'Sa')
	end

	for _, err in ipairs(errors) do
		local content = {
			('Error -> %s @ %d'):format(err.element.trace.short_src, err.element.trace.currentline),
			err.name,
		}
		writefile(content, path, 'Sa')
		writefile(vim.split(err.message, '\n'), path, 'Sa')
		writefile({''}, path, 'Sa')
	end

	return result
end

---Convert a test failure entry to a result item.
---@param failure table  Entry in the test runner output
---@return string key, neotest.Result result  The node ID and the result item
local function failure_to_result(failure, map)
	local file = vim.fn.fnamemodify(failure.element.trace.source:sub(2), ':p')
	local name = failure.name
	local key = map[file][name]
	local result = {
		status = types.ResultStatus.failed,
		errors = {
			{
				line = failure.trace.linedefined,
				-- Strip all escape character sequences.  It would be cool if
				-- we could convert escape sequences to extmarks, but I don't
				-- know if this is really feasible.
				message = failure.message:gsub('\027[^m]*m', ''),
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

	-- Need to travel up the tree until the file node and add all before_each
	-- and after_each to the map.  Why?  Suppose we run a test directly, then
	-- any before/after functions will be run and might throw errors, but they
	-- won't be included in the map.  If they then do throw an error there will
	-- be no entry in the map for them.
	local file_tree = tree
	do
		local parent = file_tree:parent()
		while parent and parent:data().type ~= 'dir' do
			file_tree = parent
			parent = file_tree:parent()
		end
	end
	local map = tree_to_map(file_tree, {})
	local result = {}

	-- Handle the different types of output items
	for _, success in ipairs(json.successes) do
		local file = vim.fn.fnamemodify(success.trace.source:sub(2), ':p')
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
		local file = vim.fn.fnamemodify(pending.trace.source:sub(2), ':p')
		local name = pending.name
		local key = map[file][name]
		result[key] = {
			status = types.ResultStatus.skipped,
			short = pending.message,
		}
	end

	return result
end
