--require("libs/cupid")

-- Libs, etc
_VECTOR = require("libs/Vec")("Vec","Vector")
_RECTANGLE = require("libs/Rec")("Rec","Rect","Rectangle")

-- States
States = {}
States["game"] = love.filesystem.isFile("states/game.lua") and require("states/game") or require("states/test")
state = States["game"]
-- UIMngr
UIMngr = {}
UIMngr["gameUI"] = love.filesystem.isFile("uis/gameUI.lua") and require("uis/gameUI") or require("uis/testUI")
uimgr = UIMngr["gameUI"]
-- "Mods"
Mods = {}
function modErr() print(">> A mod is causing trouble. Here's the lowdown:\n\t"..debug.traceback()) end

-- CORE
function love.load( ... )

	love.graphics.setDefaultFilter("nearest","nearest")
	require("constants")
	if state.load then state.load(...) end
	if uimgr.load then uimgr.load(...) end
	-- "mods" -- HOLY FUCK THIS HACK. I MEAN, THANK GOD FOR IT, BUT HOLY FUCK.
	local i, t, popen = 0, {}, io.popen
	local pfile
	if love.system.getOS()=="Windows" then
		pfile = popen('dir "'..modsDir..'" /b')
	else
		local pfile = popen('ls -a "'..modsDir..'"') -- for linux?
	end
	for filename in pfile:lines() do
		i = i + 1
		t[i] = filename
	end
	pfile:close()

	local temp = {}
	for i,v in ipairs(t) do
		local status,mod,rank = xpcall(dofile,function() print("mod "..v.." didn't load properly.") end,modsDir..'/'..v)
		if status and type(mod)=="table" then
			mod.name = mod.name or v
			rank = rank or math.huge
			table.insert(temp,{mod,rank})
		end
	end
	-- simple swapsort thing
	local sorted
	repeat
		sorted = true
		for i=1,#temp-1 do
			if temp[i][2]>temp[i+1][2] then
				sorted = false
				temp[i],temp[i+1]=temp[i+1],temp[i] -- swap
			end
		end
	until sorted
	for i,v in ipairs(temp) do
		Mods[i]=v[1]
	end

	for i,v in ipairs(Mods) do
		if v.load then
			local status,err = xpcall(v.load,modErr,...)
		end
	end
	--collectgarbage("stop")
	--collectgarbage("setpause",1)
end

function love.update( ... )
	if state.update then state.update(...) end
	if uimgr.update then uimgr.update(...) end
	for i,v in ipairs(Mods) do
		if v.update then
			local status,err = xpcall(v.update,modErr,...)
		end
	end
	--print(collectgarbage("count"))
end

function love.draw( ... )
	love.graphics.setDefaultFilter("nearest","nearest")
	if state.draw then state.draw(...) end
	if uimgr.draw then uimgr.draw(...) end
	for i,v in ipairs(Mods) do
		if v.draw then
			local status,err = xpcall(v.draw,modErr,...)
		end
	end
end

-- Control callbacks
function love.keypressed( ... )
	if state.keypressed then state.keypressed(...) end
	if uimgr.keypressed then uimgr.keypressed(...) end
	for i,v in ipairs(Mods) do
		if v.keypressed then
			local status,err = xpcall(v.keypressed,modErr,...)
		end
	end
end
function love.keyreleased( ... )
	if state.keyreleased then state.keyreleased(...) end
	if uimgr.keyreleased then uimgr.keyreleased(...) end
	for i,v in ipairs(Mods) do
		if v.keyreleased then
			local status,err = xpcall(v.keyreleased,modErr,...)
		end
	end
end

function love.mousemoved( ... )
	if state.mousemoved then state.mousemoved(...) end
	if uimgr.mousemoved then uimgr.mousemoved(...) end
	for i,v in ipairs(Mods) do
		if v.mousemoved then
			local status,err = xpcall(v.mousemoved,modErr,...)
		end
	end
end
function love.mousepressed( ... )
	if state.mousepressed then state.mousepressed(...) end
	if uimgr.mousepressed then uimgr.mousepressed(...) end
	for i,v in ipairs(Mods) do
		if v.mousepressed then
			local status,err = xpcall(v.mousepressed,modErr,...)
		end
	end
end
function love.mousereleased( ... )
	if state.mousereleased then state.mousereleased(...) end
	if uimgr.mousereleased then uimgr.mousereleased(...) end
	for i,v in ipairs(Mods) do
		if v.mousereleased then
			local status,err = xpcall(v.mousereleased,modErr,...)
		end
	end
end

-- Management
function love.quit( ... )
	if state.quit then state.quit(...) end
	if uimgr.quit then uimgr.quit(...) end
	for i,v in ipairs(Mods) do
		if v.quit then
			local status,err = xpcall(v.quit,modErr,...)
		end
	end
end
function love.visible( ... )
	if state.visible then state.visible(...) end
	if uimgr.visible then uimgr.visible(...) end
	for i,v in ipairs(Mods) do
		if v.visible then
			local status,err = xpcall(v.visible,modErr,...)
		end
	end
end
function love.resize( ... )
	if state.resize then state.resize(...) end
	if uimgr.resize then uimgr.resize(...) end
	for i,v in ipairs(Mods) do
		if v.resize then
			local status,err = xpcall(v.resize,modErr,...)
		end
	end
end

-- Misc
function love.textinput( ... )
	if state.textinput then state.textinput(...) end
	if uimgr.textinput then uimgr.textinput(...) end
	for i,v in ipairs(Mods) do
		if v.textinput then
			local status,err = xpcall(v.textinput,modErr,...)
		end
	end
end

function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
		for i=1,3 do love.math.random() end
	end
	if love.event then
		love.event.pump()
	end
	if love.load then love.load(arg) end
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
	local dt = 0
	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for e,a,b,c,d in love.event.poll() do
				if e == "quit" then
					if not love.quit or not love.quit() then
						if love.audio then
							love.audio.stop()
						end
						return
					end
				end
				love.handlers[e](a,b,c,d)
			end
		end
		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
		-- Moved before update to allow between-frame canvas rendering
		if love.window.isCreated() then
			love.graphics.clear()
		end
		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
		if love.window.isCreated() then
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end
		--if love.timer then love.timer.sleep(0.001) end
	end
end