local state = {}
game = require("libs/game")
require("libs/util")

blocks = {}
world = {entLayers = {},layerCount = 1}

function state.load()
	blocks.default = {
		frames = {
			tile = love.graphics.newImage("stockData/errorBlock.png")
		},
		properties = {
			layer = 1,
			solid = true
		}
	}

	for y = 0,chunkH do
		for x = 0,chunkW do
			game.placeBlock(world,blocks.default,x,y)
		end
	end
	state.viewPort = Rec(0,0,love.graphics.getWidth(),love.graphics.getHeight())

	local ent = {
		x = 10,
		y = 10,
		layer = 2,
		draw = function(self,x,y)
			--print("I'M ALIIIIIIVE!!")
			love.graphics.setColor(255,255,255,255)
			love.graphics.rectangle("fill",x,y,tileW,tileH)
		end,
		update = function(self,dt)
			self.x=self.x + dt
		end
	}
	game.insertEntity(world,ent)
end

function state.update(dt)

	if love.keyboard.isDown("left") then
		state.viewPort.x = state.viewPort.x - dt*300
	end
	if love.keyboard.isDown("right") then
		state.viewPort.x = state.viewPort.x + dt*300
	end
	if love.keyboard.isDown("up") then
		state.viewPort.y = state.viewPort.y - dt*300
	end
	if love.keyboard.isDown("down") then
		state.viewPort.y = state.viewPort.y + dt*300
	end

	for layer = 0,#world.entLayers do
		for i,v in ipairs(world.entLayers[layer]) do
			if v.update then
				v:update(dt)
			end
		end
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
	local chunkW,chunkH,tileW,tileH = chunkW,chunkH,tileW,tileH -- optimizing via localization
	local crx,cx,cry,cy,chunk
	for i = 0,world.layerCount do
		-- render chunks & blocks
		for y = 0,viewRect.w/chunkW/tileW+2 do
			for x = 0,viewRect.h/chunkH/tileH+2 do
				crx = x*chunkW*tileW-viewRect.x%(chunkW*tileW)
				cx = x+math.floor(viewRect.x/chunkW/tileW)
				cry = y*chunkH*tileH-viewRect.y%(chunkH*tileH)
				cy = y+math.floor(viewRect.y/chunkH/tileH)

				chunk = world[cx] and world[cx][cy] or nil

				love.graphics.reset() -- graphics reset, because we never know what's coming.

				if chunk then
					if not chunk.rendered then -- make sure chunks at least get initialized. Slow, but not unmanageable, and automatically takes care of weird errorchunks. Also allows nearly instant chunk rerendering.
						game.renderChunk(chunk)
						love.graphics.reset() -- not 100% sure about game.renderchunk yet tbh.
					end

					local v = chunk.layers[i]
					if v and v.canv then
						love.graphics.draw(v.canv,crx,cry)
					end

					if v and v.objects then 
						for i,iv in ipairs(v.objects) do
							if iv.draw then
								iv:draw(crx+(iv.x*tileW-x),crx+(iv.x*tileW-x))
							end
						end
					end
				end
			end
		end
		if world.entLayers[i] then
			for ii,iv in ipairs(world.entLayers[i]) do
				if iv.draw then
					iv:draw(iv.x*tileW-viewRect.x,iv.y*tileH-viewRect.y)
				end
			end
		end
	end
end

return state