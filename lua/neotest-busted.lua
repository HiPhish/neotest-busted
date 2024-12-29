-- See also https://lunarmodules.github.io/busted/#usage
local conf = require('neotest-busted._conf')
local lib = require('neotest.lib')

---Neotest adapter for the Busted test runner
local M = {
  name = 'Busted',
  is_test_file = require('neotest-busted._is_test_file'),
  build_spec = require('neotest-busted._build_spec'),
  results = require('neotest-busted._results'),
  filter_dir = require('neotest-busted._filter_dir'),
}

---The Tree-sitter query used to parse test files.
local query = [[
;;; Describe-block
(function_call
   name: (identifier) @_func_name (#eq? @_func_name "describe")
   arguments: (arguments
                (string
                  content: (string_content) @namespace.name)
                (function_definition))) @namespace.definition

;;; It-block
(function_call
   name: (identifier) @_func_name (#eq? @_func_name "it")
   arguments: (arguments
                (string
                  content: (string_content) @test.name)
                (function_definition))) @test.definition

;;; It-block from other frameworks like Neotest's 'nio.tests.it'
(function_call
   name: (dot_index_expression
           field: (identifier) @_func_name (#eq? @_func_name "it"))
   arguments: (arguments
                (string
                  content: (string_content) @test.name)
                (function_definition))) @test.definition

;;; Before-each calls can also fail, so they count as tests
(function_call
  name: (identifier) @test.name (#eq? @test.name "before_each")
  arguments: (arguments
               (function_definition))) @test.definition

;;; After-each calls can also fail, so they count as tests
(function_call
  name: (identifier) @test.name (#eq? @test.name "after_each")
  arguments: (arguments
               (function_definition))) @test.definition
]]

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function M.discover_positions(file_path)
  local opts = {
    nested_namespaces = true,
    require_namespaces = false,
  }
  return lib.treesitter.parse_positions(file_path, query, opts)
end

---Searches upwards from the current working directory for a file named
--`.busted`.  Sets the configuration as a side effect.
---@param path string
---@return string?
function M.root(path)
  local bustedrc = vim.g.bustedrc or '.busted'
  local result = lib.files.match_root_pattern(bustedrc)(path)
  if not result then
    return
  end
  conf.read(result)
  return result
end

return M
