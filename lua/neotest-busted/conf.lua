---Current adapter configuration.
---
---Why is this a separate module?  I want to be able to inject and restore
---settings at runtime, and I want these settings to be decoupled from the
---adapter.  Users of the module should not hold on to the result of the getter
---for too long because a new table might become the adapter settings.
local M = {}

local conf = {}

---Returns the internal settings table.
---@return table
function M.get()
	return conf
end

---@param other table  New settings table
function M.set(other)
	conf = other
end

return M
