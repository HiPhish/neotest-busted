# SPDX-License-Identifier: Unlicense

# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or distribute
# this software, either in source code form or as a compiled binary, for any
# purpose, commercial or non-commercial, and by any means.
#
# In jurisdictions that recognize copyright laws, the author or authors of
# this software dedicate any and all copyright interest in the software to
# the public domain.  We make this dedication for the benefit of the public
# at large and to the detriment of our heirs and successors.  We intend this
# dedication to be an overt act of relinquishment in perpetuity of all
# present and future rights to this software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
# AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <https://unlicense.org/>


.PHONY: check unit-test clean

check: unit-test integration-test end-to-end-test

unit-test:
	@./test/bin/busted --run unit

integration-test:
	@./test/bin/busted --run integration

end-to-end-test:
	@./test/bin/nvim --headless -c "set loadplugins" -c "luafile ./scripts/e2e.lua"

clean:
	@# Delete everything except for the trust file
	@for f in test/xdg/local/state/nvim/*; do ([ "$$(basename $$f)" != 'trust' ] && rm -r "$$f") || true; done
	@rm -rf test/xdg/local/share/nvim/site/pack/testing/start/nvim-treesitter/parser/*
