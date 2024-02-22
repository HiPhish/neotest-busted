local adapter = require 'neotest-busted'
local conf    = require 'neotest-busted.conf'
local nio = require 'nio'

local split = vim.fn.split
local writefile = vim.fn.writefile


describe('Building the test run specification', function()
	local tempfile

	---@param content string
	---@param fname   string?  Path to output file (default random file)
	---@return neotest.Tree
	local function parse_test(content, fname)
		fname = fname or tempfile
		writefile(split(content, '\n'), fname, 's')
		local result = adapter.discover_positions(fname)
		return assert(result)
	end

	before_each(function()
		tempfile = vim.fn.tempname() .. '.lua'  -- Create temporary file
	end)

	after_each(function()
		-- Delete temporary file
		if vim.fn.filereadable(tempfile) ~= 0 then
			vim.fn.delete(tempfile)
		end

	end)
	it('Returns nothing without a tree', function()
		local args = {
			strategy = 'integrated',
		}
		local spec = adapter.build_spec(args)
		assert.is_nil(spec)
	end)

	nio.tests.it('Runs file even without tests', function()
		local tree = parse_test [[
			local function add(x, y)
				if y == 0 then return x end
				return add(x + 1, y - 1)
			end

			local x, y = 2, 3
			return add(x, y)
		]]
		local expected = {'busted', '--output', 'json', '--', tempfile}
		local args = {
			strategy = 'integrated',
			tree = tree
		}
		local spec = assert(adapter.build_spec(args))
		assert.is_not_nil(spec)
		assert.are.same(expected, spec.command)
	end)

	nio.tests.it('Returns a spec for a standalone test', function()
		local tree = parse_test [[
			it('Fulfills a tautology, a self-evident 100% true statement', function()
				assert.is_true(true)
			end)
		]]
		local expected = {'busted', '--output', 'json', '--filter', 'Fulfills%sa%stautology,%sa%sself%-evident%s100%%%strue%sstatement', '--', tempfile}

		local args = {
			stategy = 'integrated',
			tree = tree:get_key(tempfile .. '::Fulfills a tautology, a self-evident 100% true statement')
		}
		local spec = assert(adapter.build_spec(args))
		assert.are.same(expected, spec.command)
	end)

	nio.tests.it('Returns a spec for a namespace', function()
		local tree = parse_test [[
			describe('Arithmetic', function()
				it('Adds two numbers', function()
					assert.is.equal(5, 2 + 3)
				end)
				it('Multiplies two numbers', function()
					assert.is.equal(6, 2 * 3)
				end)
			end)
		]]
		local expected = {'busted', '--output', 'json', '--filter', 'Arithmetic', '--', tempfile}

		local args = {
			stategy = 'integrated',
			tree = tree:get_key(tempfile .. '::Arithmetic')
		}
		local spec = assert(adapter.build_spec(args))
		assert.are.same(expected, spec.command)
	end)

	nio.tests.it('Returns a spec for a nested test', function()
		local tree = parse_test [[
			describe('Arithmetic', function()
				it('Adds two numbers', function()
					assert.is.equal(5, 2 + 3)
				end)
				it('Multiplies two numbers', function()
					assert.is.equal(6, 2 * 3)
				end)
			end)
		]]
		local expected = {'busted', '--output', 'json', '--filter', 'Arithmetic%sAdds%stwo%snumbers', '--', tempfile}

		local args = {
			stategy = 'integrated',
			tree = tree:get_key(tempfile .. '::Arithmetic::Adds two numbers')
		}
		local spec = assert(adapter.build_spec(args))
		assert.are.same(expected, spec.command)
	end)

	nio.tests.it('Picks the right taks', function()
		local tempdir = vim.fn.fnamemodify(tempfile, ':h')
		tempfile = tempdir .. '/test/unit/derp_spec.lua'
		vim.fn.mkdir(tempdir .. '/test/unit', 'p', 448)  -- 448 = 0o700

		local expected = {'busted', '--output', 'json', '--run', 'unit', '--', tempfile}
		local tree = parse_test [[
			describe('Arithmetic', function()
				it('Adds two numbers', function()
					assert.is.equal(5, 2 + 3)
				end)
				it('Multiplies two numbers', function()
					assert.is.equal(6, 2 * 3)
				end)
			end)
		]]

		conf.set {
			unit = {
				-- NOTE: there can be multiple roots
				ROOT = {tempdir .. '/test/simple', tempdir .. '/test/unit/'}
			},
			integration = {
				ROOT = {'./test/integration/'}
			},
		}

		local args = {
			stategy = 'integrated',
			tree = tree
		}
		local spec = assert(adapter.build_spec(args))
		assert.are.same(expected, spec.command)
	end)
end)
