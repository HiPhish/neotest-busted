.. default-role:: code

################
 Neotest-Busted
################

   Any sufficiently complicated Lua test framework contains an ad hoc,
   informally-specified, bug-ridden, slow implementation of half of Busted_.

This is a Neotest_ adapter for Busted_, a Lua test framework.

.. warning::

   The configuration file `.busted` contains executable Lua code and will be
   executed when looking for test files.


Installation
############

Install it like any other Neovim plugin.  Requires Neotest to be installed as
well, and `busted` to be in the `$PATH`.  It does not matter how you install
Busted; personally I prefer to use Luarocks_.


Configuration
#############

The adapter name is `Busted`.  There is no additional configuration needed
beyond the usual Neotest configuration.  You can give an explicit path to the
Busted binary by setting the `g:bustedprg` variable, otherwise the default
`busted` is used.


Status of the plugin
####################

It works, but there might be some edge cases that are not handled properly yet.
Features I have not yet attempted:

- Debugging
- Watching tests
- Custom configuration file
- Coloured output


License
#######

Licensed under the terms of the MIT (Expat) license.  See the LICENSE_ file for
details.


See also https://github.com/nvim-neotest/neotest-plenary

.. _Busted: https://lunarmodules.github.io/busted/
.. _Neotest: https://github.com/nvim-neotest/neotest
.. _Luarocks: https://luarocks.org/
.. _LICENSE: LICENSE.txt
