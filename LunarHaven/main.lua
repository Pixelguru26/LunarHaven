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

-- CORE
function love.load( ... )
	love.graphics.setDefaultFilter("nearest","nearest")
	require("constants")
	if state["load"] then state.load(...) end
	if uimgr["load"] then uimgr.load(...) end
end

function love.update( ... )
	if state["update"] then state.update(...) end
	if uimgr["update"] then uimgr.update(...) end
end

function love.draw( ... )
	love.graphics.setDefaultFilter("nearest","nearest")
	if state["draw"] then state.draw(...) end
	if uimgr["draw"] then uimgr.draw(...) end
end

-- Control callbacks
function love.keypressed( ... )
	if state["keypressed"] then state.keypressed(...) end
	if uimgr["keypressed"] then uimgr.keypressed(...) end
end
function love.keyreleased( ... )
	if state["keyreleased"] then state.keyreleased(...) end
	if uimgr["keyreleased"] then uimgr.keyreleased(...) end
end

function love.mousemoved( ... )
	if state["mousemoved"] then state.mousemoved(...) end
	if uimgr["mousemoved"] then uimgr.mousemoved(...) end
end
function love.mousepressed( ... )
	if state["mousepressed"] then state.mousepressed(...) end
	if uimgr["mousepressed"] then uimgr.mousepressed(...) end
end
function love.mousereleased( ... )
	if state["mousereleased"] then state.mousereleased(...) end
	if uimgr["mousereleased"] then uimgr.mousereleased(...) end
end

-- Management
function love.quit( ... )
	if state["quit"] then state.quit(...) end
	if uimgr["quit"] then uimgr.quit(...) end
end
function love.visible( ... )
	if state["visible"] then state.visible(...) end
	if uimgr["visible"] then uimgr.visible(...) end
end
function love.resize( ... )
	if state["resize"] then state.resize(...) end
	if uimgr["resize"] then uimgr.resize(...) end
end

-- Misc
function love.textinput( ... )
	if state["textinput"] then state.textinput(...) end
	if uimgr["textinput"] then uimgr.textinput(...) end
end