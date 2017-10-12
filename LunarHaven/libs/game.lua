-- ==========================================

	-- LUNAR HAVEN GAME LIBRARY

	-- This library is essentially a repository 
	-- of functions for interacting with the
	-- game (and game worlds') state and tapping
	-- into its core functions, such as
	-- placing and destorying blocks, etc.

-- ==========================================

local lib = {}
-- ==========================================
lib.errorBlock = love.graphics.newImage("stockData/errorBlock.png")

-- ==========================================

function lib.newChunk()
	local chunk = {}
	chunk.layers = {} -- tile layers
	--table.insert(chunk.layers[1].objects,{x=34,y=34,draw = function(self,x,y) love.graphics.rectangle("fill",x,y,tileW,tileH); print(x,y) end}) -- test entity
	return chunk
end

function lib.placeBlock(world,block,x,y)
	local chunkX = math.floor(x/chunkW)
	local chunkY = math.floor(y/chunkH)
	local i = block.layer or 1
	-- check chunk for validity
	if not world[chunkX] then
		world[chunkX] = {}
	end
	if not world[chunkX][chunkY] then
		world[chunkX][chunkY] = lib.newChunk() -- CREATE CHUNK
	end
	-- local binding
	local chunk = world[chunkX][chunkY]

	-- check block for validity and place
	if not chunk.layers[i] then
		chunk.layers[i] = {}
	end
	if not chunk.layers[i][x%chunkW] then
		chunk.layers[i][x%chunkW] = {}
	end

	-- minimal rerendering
	if block then
		chunk.layers[i][x%chunkW][y%chunkW] = block
		lib.drawBlock(block,x%chunkW*tileW,y%chunkH*tileH,chunk) -- broken atm. find out why.
		chunk.rendered = false
	else
		chunk.layers[i][x%chunkW][y%chunkW] = nil
		lib.drawBlock(nil,x%chunkW*tileW,y%chunkH*tileH,chunk)
		chunk.rendered = false
	end
end

function lib.drawBlock(block,x,y,chunk)
	if block then
		local img = block.frames.tile or lib.errorBlock
		local bm = love.graphics.getBlendMode()
		local r,g,b,a = love.graphics.getColor()
		-- quick note on the usage of those big messy chunk.layers[block.layer or 1].canv repeats: 
		--putting 'em into a local variable is MORE LAGGY. I have no fucking clue why, but it is so whatever.
		if not chunk.layers[block.layer or 1].canv then
			chunk.layers[block.layer or 1].canv = love.graphics.newCanvas(chunkW*tileW,chunkH*tileH)
		end
		love.graphics.setBlendMode("replace")
		for i,v in ipairs(chunk.layers) do
			if v.canv then
				love.graphics.setCanvas(v.canv)
				love.graphics.setColor(0,0,0,0)
				love.graphics.rectangle("fill",x,y,tileW,tileH)
			end
		end
		love.graphics.setColor(r,g,b,a)
		love.graphics.setBlendMode(bm)
		love.graphics.setCanvas(chunk.layers[block.layer or 1].canv)
		love.graphics.draw(img,x,y,0,tileW/img:getWidth(),tileH/img:getHeight())
		-- drawing light later.
	else
		local bm = love.graphics.getBlendMode()
		local r,g,b,a = love.graphics.getColor()
		love.graphics.setBlendMode("replace")
		for i,v in ipairs(chunk.layers) do
			if v.canv then
				love.graphics.setCanvas(v.canv)
				love.graphics.setColor(0,0,0,0)
				love.graphics.rectangle("fill",x,y,tileW,tileH)
			end
		end
		love.graphics.setColor(r,g,b,a)
		love.graphics.setBlendMode(bm)
	end
end

function lib.renderChunk(chunk)
	for i,v in ipairs(chunk.layers) do
		if v.canv then v.canv:clear(0,0,0,0) else v.canv = love.graphics.newCanvas(chunkW*tileW,chunkH*tileH) end
		for y = 0,chunkH do
			for x = 0,chunkW do
				if v[x] and v[x][y] then
					lib.drawBlock(v[x][y],x*tileW,y*tileH,chunk)
				end
			end
		end
	end
	chunk.rendered = true
end

-- ==========================================
return lib