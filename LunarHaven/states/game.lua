local state = {}
game = require("libs/game")
require("libs/util")

blocks = {}
world = {entLayers = {},layerCount = 1}
world.fizzix = {
	grav = 1.622,--9.807, -- gravity acceleration; but floaty.
	drag = 0.01
}

function state.load()
	blocks.default = {
		frames = {
			tile = love.graphics.newImage("stockData/defaultBlock.png")
		},
		properties = {
			layer = 1,
			solid = true
		}
	}

	for y = 20,20 do
		for x = 0,200 do
			game.placeBlock(world,blocks.default,x,y)
		end
	end
	state.viewPort = Rec(0,0,love.graphics.getWidth(),love.graphics.getHeight())

	game.insertEntity(world,require("stockData/player"))

	uimgr.hotbar[1]=blocks.default
	love.mouse.setCursor(love.mouse.newCursor(love.image.newImageData("stockData/cursor.png")))

	state.fizzRects = {}
end

function state.update(dt)
	for layer = 0,#world.entLayers do
		for i,v in ipairs(world.entLayers[layer]) do
			if v.update then
				v:update(dt,world,state)
			end
		end
	end
end

function state.draw()
	state.renderWorld(state.viewPort,world)
end

function state.keypressed(key)
	for layer = 0,#world.entLayers do
		for i,v in ipairs(world.entLayers[layer]) do
			if v.keypressed then
				v:keypressed(key)
			end
		end
	end
end

function state.resize(w,h)
	state.viewPort.w = w
	state.viewPort.h = h
end

function state.keyreleased(key)
	for layer = 0,#world.entLayers do
		for i,v in ipairs(world.entLayers[layer]) do
			if v.keyreleased then
				v:keyreleased(key)
			end
		end
	end
end

function state.mousemoved(x,y,dx,dy)
	local ox = math.floor((x+state.viewPort.x)/tileW) -- world x
	local oy = math.floor((y+state.viewPort.y)/tileH) -- world y
	for layer = 0,#world.entLayers do
		for i,v in ipairs(world.entLayers[layer]) do
			if v.mousemoved then
				v:mousemoved(x,y,ox,oy,dx,dy,world,state)
			end
		end
	end
end
function state.mousepressed(x,y,b)
	local ox = math.floor((x+state.viewPort.x)/tileW) -- world x
	local oy = math.floor((y+state.viewPort.y)/tileH) -- world y
	for layer = 0,#world.entLayers do
		for i,v in ipairs(world.entLayers[layer]) do
			if v.mousepressed then
				v:mousepressed(x,y,ox,oy,b,world,state)
			end
		end
	end
end
function state.mousereleased(x,y,b)
	local ox = math.floor((x+state.viewPort.x)/tileW) -- world x
	local oy = math.floor((y+state.viewPort.y)/tileH) -- world y
	for layer = 0,#world.entLayers do
		for i,v in ipairs(world.entLayers[layer]) do
			if v.mousereleased then
				v:mousereleased(x,y,ox,oy,b,world,state)
			end
		end
	end
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
								iv:draw(crx+((iv.bounds.x or iv.x)*tileW-x),cry+((iv.bounds.y or iv.y)*tileW-y))
							end
						end
					end
				end
			end
		end
		if world.entLayers[i] then
			for ii,iv in ipairs(world.entLayers[i]) do
				if iv.draw then
					iv:draw((iv.bounds.x or iv.x)*tileW-viewRect.x,(iv.bounds.y or iv.y)*tileH-viewRect.y)
				end
			end
		end
	end
end

return state