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


---Default configuration.  The values are taken from the help text of busted.
---@type neotestBusted.Config
M.default = {
	pattern = '_spec',
}


---The current busted configuration.
---@type neotestBusted.Config
local conf = M.default

---The current configuration file
---@type string?
local bustedrc


---The current root of the project
---@type string?
local root


local bustedrc_event, watch_bustedrc = vim.loop.new_fs_event()

---Reload the configuration from file after the configuration file has changed.
local function on_bustedrc_change(_err, fname, status)
	print(_err, fname, vim.inspect(status))
	if not status.change then return end
	bustedrc_event:stop()
	watch_bustedrc(fname)

	if not vim.secure.read(fname) then return end
	local config = loadfile(fname)()
	local t = type(config)
	if t ~= 'table' then
		error(string.format('Busted configuration is of type %s, but it needs to be table', t))
	end
	conf = config
end


---Start watching the given file for filesystem events
---@param fname string
function watch_bustedrc(fname)
	bustedrc_event:stop()
	local cb = vim.schedule_wrap(function(...) on_bustedrc_change(...) end)
	bustedrc_event:start(fname, {}, cb)
end


---Attempts to read the user's configuration from the `.busted` file.  Sets
---`conf`, `root` and `bustedrc` as side effects.
---@param path string  Path to the root of the project
---@return neotestBusted.Config? config
---@return string? root
---@return string? bustedrc
function M.read(path)
	local conf_file = string.format('%s/%s', path, vim.g.bustedrc or '.busted')
	if not vim.fn.filereadable(conf_file) then return end
	if not vim.secure.read(conf_file) then return end

	local config = loadfile(conf_file)()
	local t = type(config)
	if t ~= 'table' then
		error(string.format('Busted configuration is of type %s, but it needs to be table', t))
	end
	conf = config
	root = path
	bustedrc = conf_file
	watch_bustedrc(bustedrc)
	return config, root, conf_file
end

---Returns the currently active busted configuration.
---@return neotestBusted.Config config
---@return string? root
---@return string? bustedrc
function M.get()
	return conf, root, bustedrc
end

---Set the current active busted configuration and settings file.  It is
---possible to pass configuration without a file, in which case the old value
---(if any) will be removed.
---@param config neotestBusted.Config?  New busted configuration
---@param path   string?  Path to the settings file.
function M.set(config, path)
	conf = config or M.default
	bustedrc = path
	if bustedrc then
		watch_bustedrc(bustedrc)
	end
end

return M
