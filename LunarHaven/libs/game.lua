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

-- ========================================== Blocks & rendering

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
		if not chunk.layers[i] then -- no layerskipping
			for l = 0,i do
				if not chunk.layers[l] then
					chunk.layers[l] = {}
				end
			end
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
			for i=0,#chunk.layers do
				chunk.layers[i][x%chunkW][y%chunkW] = nil
				lib.drawBlock(nil,x%chunkW*tileW,y%chunkH*tileH,chunk)
			end
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

	function lib.getChunk(world,x,y,create)
		if world[x] and world[y] then
			return world[x][y]
		elseif create then
			world[x] = world[x] or {}
			world[x][y] = newChunk()
			return world[x][y]
		else
			return nil
		end
	end

	function lib.getTile(world,x,y)
		local chunk = lib.getChunk(world,math.floor(x/chunkW),math.floor(y/chunkH))
		if chunk then
			for i=0,world.layerCount do
				if chunk.layers[i] and chunk.layers[i][math.floor(x)%chunkW] then
					return chunk.layers[i][math.floor(x)%chunkW][math.floor(y)%chunkH]
				end
			end
		end
		return nil
	end

-- ========================================== Entities, objects & utils

function lib.placeObject(world,obj,x,y)
	local chunkX = math.floor(x/chunkW)
	local chunkY = math.floor(y/chunkH)
	local i = block.layer or 1
	world.layerCount = math.max(i,world.layerCount)
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
	if not chunk.layers[i] then -- no layerskipping
		for l = 0,i do
			if not chunk.layers[l] then
				chunk.layers[l] = {}
			end
		end
	end
	if not chunk.layers[i].objects then
		chunk.layers[i].objects = {}
	end

	table.insert(chunk.layers[i].objects,obj)
end

function lib.insertEntity(world,ent)
	local layer = ent.layer or 1
	world.layerCount = math.max(world.layerCount,layer)
	for i = 0,layer do
		if not world.entLayers[i] then
			world.entLayers[i] = {}
		end
	end
	table.insert(world.entLayers[layer],ent)
	--table.insert(world.entities,entity)
end

-- swept collisions (oh lord)
function lib.sweptCollide(v,iv,dt)
	-- find distance to collision
	local xDist = v.vel.x<0 and iv.r-v.bounds.x or iv.x-v.bounds.r
	local xEDist = v.vel.x<0 and iv.x-v.bounds.r or iv.r-v.bounds.x
	local yDist = v.vel.y<0 and iv.b-v.bounds.y or iv.y-v.bounds.b
	local yEDist = v.vel.y<0 and iv.y-v.bounds.b or iv.b-v.bounds.y

	if xDist==0 and v.bounds.b>=iv.y and v.bounds.y<=iv.b then
		return 0,v.bounds.x<iv.x and Vec(-1,0) or Vec(1,0)
	end
	if yDist==0 and v.bounds.r>=iv.x and v.bounds.x<=iv.r then
		return 0,v.bounds.y<iv.y and Vec(0,-1) or Vec(0,1)
	end

	-- find time to collision
	local xEntry = v.vel.x==0 and -math.huge or (xDist / (v.vel.x*dt))
	local xExit = v.vel.x==0 and math.huge or (xEDist / (v.vel.x*dt))
	local yEntry = v.vel.y==0 and -math.huge or (yDist / (v.vel.y*dt))
	local yExit = v.vel.y==0 and math.huge or (yEDist / (v.vel.y*dt))

	local entryTime = math.max(xEntry,yEntry)
	local exitTime = math.min(xExit,yExit)

	-- debuggin'
	--if love.keyboard.isDown(" ") then
	--	print("VEL: ",string.sub(tostring(v.vel.x),1,4),string.sub(tostring(v.vel.y),1,4),string.sub(tostring(dt),1,4))
	--	print("TME: ",entryTime)
	--end

	-- check collision for validity
	if entryTime>exitTime or xEntry>=1 or yEntry>=1 or (xEntry<0 and yEntry<0) then
		--print(entryTime>exitTime, xEntry>=1, yEntry>=1, (xEntry<0 and yEntry<0))
		return 1,Vec.zero
	end

	-- collision normal cases
	if yEntry>xEntry then
		-- y axis entry
		if v.vel.y>=0 then
			return entryTime,Vec(0,-1)
		else
			return entryTime,Vec(0,1)
		end
	else
		-- x axis entry
		if v.vel.x>0 then
			return entryTime,Vec(-1,0)
		else
			return entryTime,Vec(1,0)
		end
	end
end

-- ==========================================
return lib