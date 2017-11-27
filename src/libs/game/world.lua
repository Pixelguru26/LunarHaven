local lib = {}

-- ==========================================
lib.errorBlock = love.graphics.newImage("stockData/tiles/errorBlock.png")

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
		if block then
			local i = (block.properties and block.properties.layer) or 1
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
			if not chunk.layers[i][math.floor(x)%chunkW] then
				chunk.layers[i][math.floor(x)%chunkW] = {}
			end

			-- minimal rerendering
			chunk.layers[i][math.floor(x)%chunkW][math.floor(y)%chunkW] = block
			lib.drawBlock(block,math.floor(x)%chunkW*tileW,math.floor(y)%chunkH*tileH,chunk) -- broken atm. find out how to fix.
			-- chunk.rendered = false
		else
			-- check chunk for validity
			if not world[chunkX] then
				world[chunkX] = {}
			end
			if not world[chunkX][chunkY] then
				world[chunkX][chunkY] = lib.newChunk() -- CREATE CHUNK
			end
			-- local binding
			local chunk = world[chunkX][chunkY]

			for i=0,#chunk.layers do
				if chunk.layers[i] and chunk.layers[i][math.floor(x)%chunkW] then
					chunk.layers[i][math.floor(x)%chunkW][math.floor(y)%chunkW] = nil
					lib.drawBlock(nil,math.floor(x)%chunkW*tileW,math.floor(y)%chunkH*tileH,chunk)
				end
			end
			-- chunk.rendered = false
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
			love.graphics.setCanvas(chunk.layers[(block.properties and block.properties.layer) or 1].canv)
			love.graphics.draw(img,x,y,0,tileW/img:getWidth(),tileH/img:getHeight())
			-- drawing light later.
		else
			local bm = love.graphics.getBlendMode()
			local r,g,b,a = love.graphics.getColor()
			love.graphics.setBlendMode("replace")
			local v
			for i=0,#chunk.layers do
				v=chunk.layers[i]
				if v.canv then
					love.graphics.setCanvas(v.canv)
					love.graphics.setColor(0,0,0,0)
					love.graphics.rectangle("fill",x,y,tileW,tileH)
				end
			end
			love.graphics.setColor(r,g,b,a)
			love.graphics.setBlendMode(bm)
		end
		love.graphics.reset()
	end

	function lib.renderChunk(chunk)
		local v
		for i=0,#chunk.layers do
			v=chunk.layers[i]
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
		local items = {}
		if chunk then
			for i=0,world.layerCount do
				if chunk.layers[i] and chunk.layers[i][math.floor(x)%chunkW] then
					table.insert(items,chunk.layers[i][math.floor(x)%chunkW][math.floor(y)%chunkH])
				end
			end
		end
		if #items==1 then
			return items[1]
		elseif #items>0 then
			return items
		else
			return nil
		end
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
	if ent.load then ent:load(world,state) end
	--table.insert(world.entities,entity)
end

return lib