local nio = require 'nio'
local adapter = require 'neotest-busted'

local split = vim.fn.split
local writefile = vim.fn.writefile

describe('Discovery of test positions', function()
	local tempfile

	local function expect_positions(content, expected)
		writefile(split(content, '\n'), tempfile, 's')
		local result = adapter.discover_positions(tempfile):to_list()
		assert.are.same(expected, result)
	end

	before_each(function()
		TSEnsure('lua')
		-- Create temporary file
		tempfile = vim.fn.tempname() .. '.lua'
	end)

	after_each(function()
		-- Delete temporary file
		if vim.fn.filereadable(tempfile) ~= 0 then
			vim.fn.delete(tempfile)
		end
	end)

	nio.tests.it('Discovers nothing in an empty file', function()
		local expected = {
			{
				id = tempfile,
				path = tempfile,
				type = 'file',
				name = vim.fn.fnamemodify(tempfile, ':t'),
				range = {0, 0, 0, 0},
			}
		}
		expect_positions('', expected)
	end)

	nio.tests.it('Discovers nothing in an whitespace file', function()
		local content ='     \n     \n    \n   '
		local expected = {
			{
				id = tempfile,
				path = tempfile,
				type = 'file',
				name = vim.fn.fnamemodify(tempfile, ':t'),
				range = {4, 0, 4, 0},
			}
		}
		expect_positions(content, expected)
	end)

	nio.tests.it('Discovers nothing in ordinary Lua script', function()
		local content = [[
			local function add(x, y)
				if y == 0 then return x end
				return add(x + 1, y - 1)
			end

			local x, y = 2, 3
			return add(x, y)
		]]
		local expected = {
			{
				id = tempfile,
				path = tempfile,
				type = 'file',
				name = vim.fn.fnamemodify(tempfile, ':t'),
				range = {0, 3, 8, 0},
			}
		}
		expect_positions(content, expected)
	end)

	nio.tests.it('Discovers busted tests', function()
		local content = [[describe('Arithmetic', function()
				it('Adds two numbers', function()
					assert.are.equal(5, 2 + 3)
				end)
				it('Multiplies two numbers', function()
					assert.are.equal(6, 2 * 3)
				end)
			end)]]
		local expected = {
			{
				id = tempfile,
				path = tempfile,
				type = 'file',
				name = vim.fn.fnamemodify(tempfile, ':t'),
				range = {0, 0, 8, 0},
			}, {
				{
					id = tempfile .. '::Arithmetic',
					path = tempfile,
					name = 'Arithmetic',
					type = 'namespace',
					range = {0, 0, 7, 7},
				}, {
					{
						id = tempfile .. '::Arithmetic::Adds two numbers',
						path = tempfile,
						name = 'Adds two numbers',
						type = 'test',
						range = {1, 4, 3, 8},
					}
				}, {
					{
						id = tempfile .. '::Arithmetic::Multiplies two numbers',
						path = tempfile,
						name = 'Multiplies two numbers',
						type = 'test',
						range = {4, 4, 6, 8},
					}
				}
			}
		}

		expect_positions(content, expected)
	end)

	nio.tests.it('Discovers nested namespaces', function()
		local content = [[
			describe('Arithmetic', function()
				describe('Additive', function()
					it('Adds two numbers', function()
						assert.are.equal(5, 2 + 3)
					end)
				end)
			end)
		]]
		local expected = {
			{
				id = tempfile,
				path = tempfile,
				name = vim.fn.fnamemodify(tempfile, ':t'),
				type = "file",
				range = { 0, 3, 8, 0 },
			}, {
				{
					id = tempfile .. '::Arithmetic',
					path = tempfile,
					name = 'Arithmetic',
					type = 'namespace',
					range = {0, 3, 6, 7},
				}, {
					{
						id = tempfile .. '::Arithmetic::Additive',
						path = tempfile,
						name = 'Additive',
						type = 'namespace',
						range = {1, 4, 5, 8},
					}, {
						{
							id = tempfile .. '::Arithmetic::Additive::Adds two numbers',
							path = tempfile,
							name = 'Adds two numbers',
							type = 'test',
							range = { 2, 5, 4, 9 },
						}
					}
				}
			}
		}
		expect_positions(content, expected)
	end)

	nio.tests.it('Discovers parallel namespaces', function()
		local content = [[
			describe('Additive Arithmetic', function()
				it('Adds two numbers', function()
					assert.are.equal(5, 2 + 3)
				end)
			end)
			describe('Multiplicative Arithmetic', function()
				it('Multiplies two numbers', function()
					assert.are.equal(6, 2 * 3)
				end)
			end)
		]]
		local expected = {
			{
				id = tempfile,
				path = tempfile,
				name = vim.fn.fnamemodify(tempfile, ':t'),
				type = "file",
				range = { 0, 3, 11, 0 },
			}, {
				{
					id = tempfile .. '::Additive Arithmetic',
					path = tempfile,
					name = 'Additive Arithmetic',
					type = 'namespace',
					range = {0, 3, 4, 7},
				}, {
					{
						id = tempfile .. '::Additive Arithmetic::Adds two numbers',
						path = tempfile,
						name = 'Adds two numbers',
						type = 'test',
						range = {1, 4, 3, 8},
					},
				}
			}, {
				{
					id = tempfile .. '::Multiplicative Arithmetic',
					path = tempfile,
					name = 'Multiplicative Arithmetic',
					type = 'namespace',
					range = {5, 3, 9, 7},
				}, {
					{
						id = tempfile .. '::Multiplicative Arithmetic::Multiplies two numbers',
						path = tempfile,
						name = 'Multiplies two numbers',
						type = 'test',
						range = {6, 4, 8, 8},
					}
				}
			},
		}
		expect_positions(content, expected)
	end)
end)