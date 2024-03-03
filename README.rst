.. default-role:: code

################
 Neotest-Busted
################

   Any sufficiently complicated Lua test framework contains an ad hoc,
   informally-specified, bug-ridden, slow implementation of half of Busted_.

This is a Neotest_ adapter for Busted_, a Lua test framework.

.. image:: https://github.com/HiPhish/neotest-busted/assets/4954650/4ca74545-ca95-4e0b-ad32-b8d89c51b4f5
   :alt: Screenshot of Neovim showing off the Neotest summary with busted tests

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
- Coloured output


License
#######

Licensed under the terms of the MIT (Expat) license.  See the LICENSE_ file for
details.


Alternatives
############

Here are some other projects with similar goals.

- `MisanthropicBit/neotest-busted`_
- `nvim-neotest/neotest-plenary`_

.. _Busted: https://lunarmodules.github.io/busted/
.. _Neotest: https://github.com/nvim-neotest/neotest
.. _Luarocks: https://luarocks.org/
.. _LICENSE: LICENSE.txt
.. _`MisanthropicBit/neotest-busted`: https://github.com/MisanthropicBit/neotest-busted
.. _`nvim-neotest/neotest-plenary`: https://github.com/nvim-neotest/neotest-plenary
