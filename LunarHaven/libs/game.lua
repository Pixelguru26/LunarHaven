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
	chunk.entities = {} -- all "living" entities; moving, etherial buggers such as players and pets.
	chunk.objects = {} -- all non-tile objects; blocks with extra functionality at the cost of increased lag.
	-- not included: [x][y] tiles, these are stored in the base chunk later
	chunk.canv = love.graphics.newCanvas(tileW*chunkW,tileH*chunkH) -- final render canvas
	love.graphics.setColor(255,0,0,255)
	love.graphics.rectangle("fill",20,20,20,20)
	love.graphics.setColor(255,255,255,255)
	chunk.light = love.graphics.newCanvas(tileW*chunkW,tileH*chunkH) -- final lighting canvas
	return chunk
end

function lib.placeBlock(world,block,x,y)
	local chunkX = math.floor(x/chunkW)
	local chunkY = math.floor(y/chunkH)
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
	if not chunk[x] then
		chunk[x] = {}
	end

	chunk[x][y] = block
	-- DO SERVER SHIT HERE

	-- minimal rerendering
	if block then
		--lib.drawBlock(block,x%chunkW*tileW,y%chunkH*tileH,chunk.canv,chunk.light) -- broken atm. find out why.
		chunk.rendered = false
	else
		-- clear space
	end
end

function lib.drawBlock(block,x,y,canv,light)
	local img = block.frames.tile or lib.errorBlock
	love.graphics.setCanvas(canv)
	love.graphics.draw(img,x,y,0,tileW/img:getWidth(),tileH/img:getHeight())
	-- drawing light later.
end


-- TEMPORARILY NEEDLESS.
function lib.renderChunk(chunk)
	for y = 0,chunkH do
		for x = 0,chunkW do
			if chunk[x] and chunk[x][y] then
				lib.drawBlock(chunk[x][y],x*tileW,y*tileH,chunk.canv,chunk.light)
			end
		end
	end
	chunk.rendered = true
end

-- ==========================================
return lib