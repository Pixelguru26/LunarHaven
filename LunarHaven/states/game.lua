local state = {}
game = require("libs/game")
require("libs/util")

blocks = {}
world = {entLayers = {}}

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
	for y = 0,viewRect.w/chunkW/tileW+2 do
		for x = 0,viewRect.h/chunkH/tileH+2 do
			if world[x+math.floor(viewRect.x/chunkW/tileW)] and world[x+math.floor(viewRect.x/chunkW/tileW)][y+math.floor(viewRect.y/chunkH/tileH)] then
				local chunk = world[x+math.floor(viewRect.x/chunkW/tileW)][y+math.floor(viewRect.y/chunkH/tileH)]
				love.graphics.reset() -- graphics reset, because we never know what's coming.
				if not chunk.rendered then -- make sure chunks at least get initialized. Slow, but not unmanageable, and automatically takes care of weird errorchunks. Also allows nearly instant chunk rerendering.
					game.renderChunk(chunk)
					love.graphics.reset() -- not 100% sure about game.renderchunk yet tbh.
				end
				-- precalculate chunk rendering positions for later use
				local crx = x*chunkW*tileW-viewRect.x%(chunkW*tileW)
				local cry = y*chunkH*tileH-viewRect.y%(chunkH*tileH)

				local lCount = math.max(chunk and #chunk.layers or 0,#world.entLayers)
				for i=0,lCount do -- render chunk blocks
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
					if world.entLayers[i] then
						for i,iv in ipairs[world.entLayers[i]] do
							if isWithin2D(iv.x,iv.y,x*chunkW,y*chunkH,x*chunkW+chunkW,y*chunkH+chunkH) and iv.draw then
								iv:draw(iv.x-viewRect.x,iv.y-viewRect.y)
							end
						end
					end
				end

				-- show chunk, just to make sure
				--love.graphics.setColor(0,255,0,100)
				--love.graphics.rectangle("line",crx,cry,chunkW*tileW,chunkH*tileH)
			--else
			--	-- precalculate chunk rendering positions for later use
			--	local crx = x*chunkW*tileW-viewRect.x%(chunkW*tileW)
			--	local cry = y*chunkH*tileH-viewRect.y%(chunkH*tileH)
			--	-- show chunk
			--	love.graphics.setColor(255,0,0,100)
			--	love.graphics.rectangle("line",crx,cry,chunkW*tileW,chunkH*tileH)
			end
		end
	end
end

return state