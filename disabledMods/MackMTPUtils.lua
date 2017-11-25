-- utils for a budding dev on the server. No copyright, stuff's nonstandard, do as you please.
-- have fun buddy = w =

local lib = {} -- declare instance of a library
lib.name = "MackLib" -- this will be the name of the library; used dynamically.

function exec( ... ) -- Mack's mod executor; executes files in /src/mods/; no protection! use at your own risk!
	local args={...} -- compile variable args into a list for iteration
	for i,v in ipairs(args) do -- iterate over arguments
		dofile(love.filesystem.getSource().."/mods/"..v..".lua") -- run file in "LunarHaven/src/mods/" with name arg".lua"
	end -- end loop
end -- end of exec function declaration


-- ==========================================


local mod = {} -- declare mod instance

function mod.load( ... ) -- mod loading function; takes variable args in "..."
	print("implementing MackMTPUtils! If you don't want this, remove \"MackMTPUtils.lua\" from your mods folder!") -- confirmation message

	_G[lib.name]=lib -- implement lib in global table

	-- plr = world.entLayers[2][1] -- standard player accessor; implemented in prealpha, may be removed in future.

	-- ========================================== some physics tweaks.
	world.fizzix.grav = 50
	plr.stats.jump = 16
end -- end mod load function

return mod -- return instance to manager