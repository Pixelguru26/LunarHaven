-- ==========================================

	-- LUNAR HAVEN GAME LIBRARY

	-- This library is essentially a repository 
	-- of functions for interacting with the
	-- game (and game worlds') state and tapping
	-- into its core functions, such as
	-- placing and destorying blocks, etc.

-- ==========================================

local lib = {}
local libmeta = {}
function libmeta.__index(t,k)
	for ik,v in pairs(t) do
		if type(v)=="table" then
			if v[k] then
				return v[k]
			end
		end
	end
end
setmetatable(lib,libmeta)

lib.world = require("libs/game/world")
lib.fizzix = require("libs/game/fizzix")
lib.control = require("libs/game/control")
lib.system = require("libs/game/system")

-- ==========================================
return lib