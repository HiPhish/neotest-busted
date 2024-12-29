local adapter = require('neotest-busted')
local conf = require('neotest-busted._conf')
local nio = require('nio')
local types = require('neotest.types')

local split = vim.fn.split
local writefile = vim.fn.writefile

describe('Building the test run specification', function()
  local tempfile

  ---Convenience wrapper which takes care of all common steps and side
  ---effects to produce a Neotest run specification.
  ---
  ---@param content string   Test file content as a string
  ---@param key     string?  Key into the node tree to get the tree of the test
  ---@return neotest.RunSpec
  local function build_spec(content, key)
    writefile(split(content, '\n'), tempfile, 's')
    local tree =
      nio.tests.with_async_context(adapter.discover_positions, tempfile)
    local args = {
      stategy = 'integrated',
      tree = key and tree:get_key(key) or tree,
    }
    return assert(adapter.build_spec(args))
  end

  before_each(function() -- Create temporary file
    tempfile = vim.fn.tempname() .. '.lua'
  end)

  after_each(function() -- Delete temporary file
    if vim.fn.filereadable(tempfile) ~= 0 then
      vim.fn.delete(tempfile)
    end
  end)

  it('Returns nothing without a tree', function()
    local spec = adapter.build_spec({
      strategy = 'integrated',
      tree = nil,
    })
    assert.is_nil(spec)
  end)

  it('Runs file even without tests', function()
    local spec = build_spec([[
			local function add(x, y)
				if y == 0 then return x end
				return add(x + 1, y - 1)
			end

			local x, y = 2, 3
			return add(x, y)
		]])

    local expected = { 'busted', '--output', 'json', '--', tempfile }
    assert.are.same(expected, spec.command)
  end)

  it('Returns a spec for a standalone test', function()
    local content = [[
			it('Fulfills a tautology, a self-evident 100% true statement', function()
				assert.is_true(true)
			end)
		]]
    local key = tempfile
      .. '::Fulfills a tautology, a self-evident 100% true statement'
    local spec = build_spec(content, key)

    local expected = {
      'busted',
      '--output',
      'json',
      '--filter',
      'Fulfills%sa%stautology,%sa%sself%-evident%s100%%%strue%sstatement',
      '--',
      tempfile,
    }
    assert.are.same(expected, spec.command)
  end)

  it('Returns a spec for a namespace', function()
    local content = [[
			describe('Arithmetic', function()
				it('Adds two numbers', function()
					assert.is.equal(5, 2 + 3)
				end)
				it('Multiplies two numbers', function()
					assert.is.equal(6, 2 * 3)
				end)
			end)
		]]
    local spec = build_spec(content, tempfile .. '::Arithmetic')

    local expected = {
      'busted',
      '--output',
      'json',
      '--filter',
      'Arithmetic',
      '--',
      tempfile,
    }
    assert.are.same(expected, spec.command)
  end)

  it('Returns a spec for a nested test', function()
    local content = [[
			describe('Arithmetic', function()
				it('Adds two numbers', function()
					assert.is.equal(5, 2 + 3)
				end)
				it('Multiplies two numbers', function()
					assert.is.equal(6, 2 * 3)
				end)
			end)
		]]
    local spec =
      build_spec(content, tempfile .. '::Arithmetic::Adds two numbers')

    local expected = {
      'busted',
      '--output',
      'json',
      '--filter',
      'Arithmetic%sAdds%stwo%snumbers',
      '--',
      tempfile,
    }
    assert.are.same(expected, spec.command)
  end)

  describe('Using custom configuration', function()
    local old_config

    before_each(function() -- Inject new tempfile and config
      old_config = conf.get()
    end)

    after_each(function() -- Restore old config
      conf.set(old_config)
    end)

    it('Picks the right task', function()
      local tempdir = vim.fn.fnamemodify(tempfile, ':h')
      tempfile = tempdir .. '/test/unit/derp_spec.lua'
      vim.fn.mkdir(tempdir .. '/test/unit', 'p', 448) -- 448 = 0o700
      conf.set({
        unit = {
          -- NOTE: there can be multiple roots
          ROOT = { tempdir .. '/test/simple', tempdir .. '/test/unit/' },
        },
        integration = {
          ROOT = { './test/integration/' },
        },
      })

      local spec = build_spec([[
				describe('Arithmetic', function()
					it('Adds two numbers', function()
						assert.is.equal(5, 2 + 3)
					end)
					it('Multiplies two numbers', function()
						assert.is.equal(6, 2 * 3)
					end)
				end)
			]])

      local expected =
        { 'busted', '--output', 'json', '--run', 'unit', '--', tempfile }
      assert.are.same(expected, spec.command)
    end)

    it('Specifies the bustedrc file', function()
      conf.set({ _all = { verbose = true } }, 'bustedrc')
      local spec = build_spec('')
      local expected = {
        'busted',
        '--output',
        'json',
        '--config-file',
        'bustedrc',
        '--',
        tempfile,
      }
      assert.are.same(expected, spec.command)
    end)
  end)

  describe('Using a custom busted executable', function()
    after_each(function()
      vim.g.bustedprg = nil
    end)

    it('Uses the custom executable', function()
      vim.g.bustedprg = './test/busted'
      local spec = build_spec('')
      local expected = { './test/busted', '--output', 'json', '--', tempfile }
      assert.are.same(expected, spec.command)
    end)

    it('Splices in a custom busted command list', function()
      vim.g.bustedprg = { 'busted', '--verbose' }
      local spec = build_spec('')
      local expected =
        { 'busted', '--verbose', '--output', 'json', '--', tempfile }
      assert.are.same(expected, spec.command)
    end)
  end)

  describe('Running multiple roots', function()
    local old_config

    before_each(function() -- Inject new configuration
      old_config = conf.get()
      local config = {
        unit = {
          ROOT = { 'test/unit' },
        },
        integration = {
          ROOT = { 'test/integration' },
        },
        insource = {
          ROOT = { 'src' },
        },
      }
      conf.set(config, 'bustedrc')
    end)

    after_each(function() -- Restore old config
      conf.set(old_config)
    end)

    it('Runs all tasks with matching roots', function()
      local expected = {
        {
          command = {
            'busted',
            '--output',
            'json',
            '--config-file',
            'bustedrc',
            '--run',
            'integration',
            '--',
            'test/integration',
          },
        },
        {
          command = {
            'busted',
            '--output',
            'json',
            '--config-file',
            'bustedrc',
            '--run',
            'unit',
            '--',
            'test/unit',
          },
        },
      }

      -- A directory tree which contains two more directory trees which
      -- are part of the roots.
      local t = {
        {
          id = 'test',
          name = 'test',
          path = 'test',
          type = 'dir',
        },
        {
          {
            id = 'test/integration',
            name = 'test/integration',
            path = 'test/integration',
            type = 'dir',
          },
          {
            {
              id = 'test/integration/foo_spec.lua',
              name = 'foo_spec.lua',
              path = 'test/integration/foo_spec.lua',
              range = { 0, 0, 4, 0 },
              type = 'file',
            },
            {
              {
                id = 'test/integration/foo_spec.lua::Does something',
                name = 'Does something',
                path = 'test/integration/foo_spec.lua',
                range = { 0, 0, 4, 0 },
                type = 'test',
              },
            },
          },
        },
        {
          {
            id = 'test/unit',
            name = 'test/unit',
            path = 'test/unit',
            type = 'dir',
          },
          {
            {
              id = 'test/unit/foo_spec.lua',
              name = 'foo_spec.lua',
              path = 'test/unit/foo_spec.lua',
              range = { 0, 0, 4, 0 },
              type = 'file',
            },
            {
              {
                id = 'test/unit/foo_spec.lua::Does something',
                name = 'Does something',
                path = 'test/unit/foo_spec.lua',
                range = { 0, 0, 4, 0 },
                type = 'test',
              },
            },
          },
        },
      }
      local dir_tree = types.Tree.from_list(t, function(pos)
        return pos.id
      end)
      local spec =
        assert(adapter.build_spec({ tree = dir_tree, strategy = 'integrated' }))

      -- NOTE: The order of specifications is undefined, so we need to
      -- explicitly sort the two list.
      local function comp(t1, t2)
        return t1.command[7] < t2.command[7]
      end
      table.sort(expected, comp)
      table.sort(spec, comp)
      assert.are.same(expected, spec)
    end)
  end)
end)
