---Current adapter configuration.
---
---Why is this a separate module?  I want to be able to inject and restore
---settings at runtime, and I want these settings to be decoupled from the
---adapter.  Users of the module should not hold on to the result of the getter
---for too long because a new table might become the adapter settings.
local M = {}

---User configuration for running busted.
---@class neotestBusted.Config
---@field ROOT      string[]?
---@field pattern   string?
---@field directory string?
---@field output    string?
---@field tags      string[]?
---@field filter    string[]?
---@field lpath     string?
---@field cpath     string?
---@field run       string?
---@field repeat    integer?
---@field seed      integer?
---@field lang      string?
---@field helper    string?
---@field lua       string?
---@field Xoutput   string[]?
---@field Xhelper   string[]?
---@field coverage  boolean?
---@field verbose   boolean?
---@field lazy      boolean?
---@field recursive boolean?
---@field sort      boolean?
---@field shuffle   boolean?
---@field ['config-file']      string?
---@field ['exclude-tags']     string[]?
---@field ['filter-out']       string[]?
---@field ['enable-sound']     string[]?
---@field ['ignore-lua']       string[]?
---@field ['auto-insulate']    string[]?
---@field ['keep-going']       string[]?
---@field ['shuffle-files']    string[]?
---@field ['shuffle-tests']    string[]?
---@field ['sort-files']       string[]?
---@field ['sort-tests']       string[]?
---@field ['suppress-pending'] string[]?
---@field ['defer-print']      string[]?


---The current busted configuration.
---@type neotestBusted.Config
local conf = {}

---The current configuration file
---@type string?
local bustedrc

---Default configuration.  The values are taken from the help text of busted.
---@type neotestBusted.Config
M.default = {
	pattern = '_spec',
}

---Attempts to read the user's configuration from the `.busted` file.
---@param root string  Path to the root of the project
---@return neotestBusted.Config? config, string? bustedrc
function M.read(root)
	local path = string.format('%s/%s', root, vim.g.bustedrc or '.busted')
	if not vim.fn.filereadable(path) then return end
	if not vim.secure.read(path) then return end

	local result = loadfile(path)()
	local t = type(result)
	if t ~= 'table' then
		error(string.format('Busted configuration is of type %s, but it needs to be table', t))
	end
	return result, path
end

---Returns the currently active busted configuration.
---@return neotestBusted.Config config, string? bustedrc
function M.get()
	return conf, bustedrc
end

---Set the current active busted configuration and settings file.  It is
---possible to pass configuration without a file, in which case the old value
---(if any) will be removed.
---@param config neotestBusted.Config  New busted configuration
---@param path   string?  Path to the settings file.
function M.set(config, path)
	conf = config
	bustedrc = path
end

return M
