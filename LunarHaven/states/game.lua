local state = {}
game = require("libs/game")

blocks = {}
world = {}

function state.load()
	blocks.default = {
		frames = {
			tile = love.graphics.newImage("stockData/defaultBlock.png")
		}
	}
	for y=1,5 do
		for x = 1,20 do
			game.placeBlock(world,blocks.default,x,y)
		end
	end
	state.viewPort = Rec(0,0,love.graphics.getWidth(),love.graphics.getHeight())
end

function state.update(dt)
	if love.keyboard.isDown("left") then
		state.viewPort.x = state.viewPort.x - dt*100
	end
	if love.keyboard.isDown("right") then
		state.viewPort.x = state.viewPort.x + dt*100
	end
	if love.keyboard.isDown("up") then
		state.viewPort.y = state.viewPort.y - dt*100
	end
	if love.keyboard.isDown("down") then
		state.viewPort.y = state.viewPort.y + dt*100
	end
end

function state.draw()
	state.renderWorld(state.viewPort,world)
end

function state.resize(w,h)
	state.viewPort.w = w
	state.viewPort.h = h
end

-- lib stuff?

function state.renderWorld(viewRect,world)
	for y = 0,viewRect.w/chunkW/tileW+2 do
		for x = 0,viewRect.h/chunkH/tileH+2 do
			--print("iterating over "..x+math.floor(viewRect.x/chunkW/tileW)..", "..y+math.floor(viewRect.y/chunkH/tileH))
			if world[x+math.floor(viewRect.x/chunkW/tileW)] then
				local chunk = world[x+math.floor(viewRect.x/chunkW/tileW)][y+math.floor(viewRect.y/chunkH/tileH)]
				if chunk then
					if chunk.canv then
						if not chunk.rendered then
							game.renderChunk(chunk)
						end
						-- graphics reset, because we never know what's coming.
						love.graphics.reset()
						-- render chunk
						love.graphics.draw(chunk.canv,x*chunkW*tileW-viewRect.x%(chunkW*tileW),y*chunkH*tileH-viewRect.y%(chunkH*tileH))
						-- ‽‽‽‽
						--love.graphics.setColor(255,0,0,40)
						--love.graphics.rectangle("line",x*chunkW*tileW-viewRect.x%(chunkW*tileW),y*chunkH*tileH-viewRect.y%(chunkH*tileH),chunkW*tileW,chunkH*tileH)
					end
				end
			end
			--if not world[x+math.floor(viewRect.x/chunkW/tileW)] or not world[x+math.floor(viewRect.x/chunkW/tileW)][y+math.floor(viewRect.y/chunkH/tileH)] then
			--	-- ‽‽‽‽
			--	love.graphics.setColor(0,0,255,40)
			--	love.graphics.rectangle("line",x*chunkW*tileW-viewRect.x%(chunkW*tileW),y*chunkH*tileH-viewRect.y%(chunkH*tileH),chunkW*tileW,chunkH*tileH)
			--end
		end
	end
end

return state