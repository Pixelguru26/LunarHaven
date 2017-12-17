-- standard utilities for prealpha. 

local mod = {}

function mod.load()
	print("Hello! It is I, stdutils.lua! Modding support is live!") -- confirmation message.

	plr = world.entLayers[2][1] -- simple player hook/shortcut; used primarily for hacks.
end

return mod,0