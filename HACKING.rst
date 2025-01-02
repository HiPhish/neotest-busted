.. default-role:: code


###########################
 Hacking on Neotest-Busted
###########################


Testing Neotest-Busted
######################

This plugin can be tested using Neotest if everything has been set up correctly.


Taking a new sample
###################

How to generate the samples found in `test/unit/samples/`

1. Run the following Lua script with `content` set to the file content of the
   test

   .. code:: lua

      -- Replace with actual test content
      local content = [[
      it('Always succeeds', function()
	      assert.is_true(true)
      end)
      ]]

      vim.fn.writefile(vim.fn.split(content, '\n'), 'throwaway.lua', 's')
      local s = vim.fn.system {
          './test/busted',
          '--output', 'json',
          '--', 'throwaway.lua'
      }
      local output = vim.json.decode(vim.split(s, '\n')[1])
      print(vim.inspect(output))

2. Copy-paste the output representation to a sample file as the `output`
   object.
3. Replace all references to `throwaway.lua` with `tempname`.
4. Sort the table entries to your liking
