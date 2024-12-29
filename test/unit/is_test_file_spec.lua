local adapter = require('neotest-busted')
local conf = require('neotest-busted._conf')

describe('Test file detection', function()
  local original_conf = conf.get()

  before_each(function() -- Inject a fake configuration
    conf.set({
      _all = {},
      default = {},
      unit = {
        ROOT = { 'test/unit', 'test/simple' },
      },
      e2e = {
        ROOT = { 'test/e2e' },
        pattern = '', -- No special pattern for E2E tests
      },
      integration = {
        ROOT = { 'test/integration' },
        pattern = 'test_%S+', -- Pytest style
      },
    })
  end)

  after_each(function()
    conf.set(original_conf)
  end)

  it('Rejects non-Lua unit files', function()
    local fname = 'test/unit/foo_spec.txt'
    assert.is_false(
      adapter.is_test_file(fname),
      'Test file should have been rejected'
    )
  end)

  it('Rejects non-Lua E2E files', function()
    local fname = 'test/e2e/foo_spec.txt'
    assert.is_false(
      adapter.is_test_file(fname),
      'Test file should have been rejected'
    )
  end)

  it('Accepts unit test which matches the pattern', function()
    local fnames = { 'test/unit/foo_spec.lua', 'test/unit/foo/bar_spec.lua' }
    for _, fname in ipairs(fnames) do
      assert.is_true(
        adapter.is_test_file(fname),
        'Test file should have been accepted'
      )
    end
  end)

  it('Rejects unit test which does not match the pattern', function()
    local fnames = { 'test/unit/foo.lua', 'test/unit/foo/bar.lua' }
    for _, fname in ipairs(fnames) do
      assert.is_false(
        adapter.is_test_file(fname),
        'Test file should have been rejected'
      )
    end
  end)

  it('Accepts E2E test with any name', function()
    local fnames =
      { 'test/e2e/foo_spec.lua', 'test/e2e/foo.lua', 'test/e2e/foo/bar.lua' }
    for _, fname in ipairs(fnames) do
      assert.is_true(
        adapter.is_test_file(fname),
        'Test file should have been accepted'
      )
    end
  end)

  it('Accepts a default test which matches the pattern', function()
    local fnames = { 'test/foo_spec.lua', 'test/foo/bar_spec.lua' }
    for _, fname in ipairs(fnames) do
      assert.is_true(
        adapter.is_test_file(fname),
        'Test file should have been accepted'
      )
    end
  end)

  it('Rejects a default test which does not match the pattern', function()
    local fnames = { 'test/foo.lua', 'test/foo/bar.lua' }
    for _, fname in ipairs(fnames) do
      assert.is_false(
        adapter.is_test_file(fname),
        'Test file should have been rejected'
      )
    end
  end)

  it('Accepts non-literal pattern matches', function()
    local fnames =
      { 'test/integration/test_foo.lua', 'test/integration/foo/test_bar.lua' }
    for _, fname in ipairs(fnames) do
      assert.is_true(
        adapter.is_test_file(fname),
        'Test file should have been accepted'
      )
    end
  end)

  it('Rejects non-literal pattern mismatches', function()
    local fnames = {
      'test/integration/testing_foo.lua',
      'test/integration/foo/testing_bar.lua',
    }
    for _, fname in ipairs(fnames) do
      assert.is_false(
        adapter.is_test_file(fname),
        'Test file should have been rejected'
      )
    end
  end)

  it('Accepts test files in default root', function()
    local fnames = { 'src/foo_spec.lua', 'src/foo/bar_spec.lua' }
    for _, fname in ipairs(fnames) do
      assert.is_true(
        adapter.is_test_file(fname),
        'Test file should have been accepted'
      )
    end
  end)

  it('Rejects source files in default root', function()
    local fnames = { 'src/foo.lua', 'src/foo/bar.lua' }
    for _, fname in ipairs(fnames) do
      assert.is_false(
        adapter.is_test_file(fname),
        'Source file should have been rejected'
      )
    end
  end)

  describe('Without roots', function()
    before_each(function()
      conf.set({
        _all = {
          pattern = '_spec',
        },
      })
    end)

    it('Rejects source file', function()
      local result = adapter.is_test_file('src/foo.lua')
      assert.is_false(result, 'Source file should have been rejected')
    end)

    it('Detects test file', function()
      local result = adapter.is_test_file('src/foo_spec.lua')
      assert.is_true(result, 'Source file should have been rejected')
    end)
  end)
end)
