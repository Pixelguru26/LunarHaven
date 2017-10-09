--require("libs/cupid")

-- Libs, etc
_VECTOR = require("libs/Vec")("Vec","Vector")
_RECTANGLE = require("libs/Rec")("Rec","Rect","Rectangle")

-- States
States = {}
States["game"] = love.filesystem.isFile("states/game.lua") and require("states/game") or require("states/test")
state = States["game"]

-- CORE
function love.load( ... )
	love.graphics.setDefaultFilter("nearest","nearest")
	require("constants")
	if state["load"] then state.load(...) end
end

function love.update( ... )
	if state["update"] then state.update(...) end
end

function love.draw( ... )
	love.graphics.setDefaultFilter("nearest","nearest")
	if state["draw"] then state.draw(...) end
end

-- Control callbacks
function love.keypressed( ... )
	if state["keypressed"] then state.keypressed(...) end
end
function love.keyreleased( ... )
	if state["keyreleased"] then state.keyreleased(...) end
end

function love.mousemoved( ... )
	if state["mousemoved"] then state.mousemoved(...) end
end
function love.mousepressed( ... )
	if state["mousepressed"] then state.mousepressed(...) end
end
function love.mousereleased( ... )
	if state["mousereleased"] then state.mousereleased(...) end
end

-- Management
function love.quit( ... )
	if state["quit"] then state.quit(...) end
end
function love.visible( ... )
	if state["visible"] then state.visible(...) end
end
function love.resize( ... )
	if state["resize"] then state.resize(...) end
end

-- Misc
function love.textinput( ... )
	if state["textinput"] then state.textinput(...) end
end