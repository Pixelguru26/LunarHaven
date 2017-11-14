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

-- swept collisions (oh lord)
lib.fizzix = {}

function lib.fizzix.sweptCollide(v,iv,dt)
	-- find distance to collision
	local xDist = v.vel.x<0 and iv.r-v.bounds.x or iv.x-v.bounds.r
	local xEDist = v.vel.x<0 and iv.x-v.bounds.r or iv.r-v.bounds.x
	local yDist = v.vel.y<0 and iv.b-v.bounds.y or iv.y-v.bounds.b
	local yEDist = v.vel.y<0 and iv.y-v.bounds.b or iv.b-v.bounds.y

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
		return 1,Vec(1,1)
	end

	-- collision normal cases
	if yDist==0 then
		if v.bounds.b<=iv.y then
			return 0,Vec(0,-1)
		else
			return 0,Vec(0,1)
		end
	elseif xDist==0 then
		if v.bounds.x<=iv.x then
			return 0,Vec(-1,0)
		else
			return 0,Vec(1,0)
		end
	end
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


	-- THESE ARE INTENDED TO BE CALLED IN PLAYER'S UPDATE FUNCTION. THEY MAY BE USED BY ANY ENTITY, BUT USUALLY REQUIRE SIMILAR STRUCTURE.
function lib.fizzix.gatherPotential(self,world,blacklist,rdt)
	local surroundings = {}
	local broadphase = self.bounds:copy(
		math.min(0,self.vel.x*rdt),
		math.min(0,self.vel.y*rdt),
		math.max(0,self.vel.x*rdt)-math.min(0,self.vel.x*rdt),
		math.max(0,self.vel.y*rdt)-math.min(0,self.vel.y*rdt)
	)
	local minTile = Rec(math.floor(broadphase.x),math.floor(broadphase.y-0.1),1,1)
	for space in broadphase:iter(minTile) do
		tile = game.getTile(world,space.x,space.y)
		if tile and tile.properties.solid then
			local v = {Rec(space.x,space.y,1,1),tile}
			local allowed = true -- blacklist implementation
			for ii,iv in ipairs(blacklist) do
				allowed = allowed and v==iv
			end
			if allowed then table.insert(surroundings,v) end

		-- debug potential collisions
		-- 	table.insert(self.fizzRects, Rec(space.x,space.y,1,1))
		-- 	print(Rec(space.x,space.y,1,1))
		-- else
		-- 	table.insert(self.fizzRects, Rec(space.x+.1,space.y+.1,.8,.8))
		-- 	print(Rec(space.x,space.y,1,1))
		end
	end
	return surroundings
end

function lib.fizzix.testCollision(self,potential,rdt)
	local soonest = nil
	for i,v in ipairs(potential) do
		local coll = {lib.fizzix.sweptCollide(self,v[1],rdt)} -- collision data
		coll.iv = v[2] -- not the most elegant way to store the original tile, but it works.
		-- collision "sorting"
		if soonest and soonest[1]<coll[1] then
			soonest = coll
		elseif not soonest then
			soonest = coll
		end
	end
	return soonest
end

function lib.fizzix.react(self,collision,blacklist,rdt)
	if collision and collision[1]>=0 and collision[1]<1 then
		if collision[2].y==-1 then self.onGround = true end
		self.bounds.pos=self.bounds.pos+self.vel*(collision[1]*rdt) -- apply collision snapping
		self.vel = self.vel * collision[2].rev.abs -- apply collision to velocity
		--print(self.vel,collision[2])

		if not walking then 
			self.vel = self.vel / (1 + (collision.iv.properties.fric or 1)*(self.stats and self.stats.fric or 1)*rdt) -- normal friction
			if self.onGround then 
				self.vel.x = self.vel.x / (1+(collision.iv.properties.fric or 1)*(self.stats and self.stats.stumble or 1)*rdt) -- stumble friction
			end
		end

		table.insert(blacklist,collision.iv)
		if collision[1]~=0 then --[[print("impact!");]]return true,rdt-collision[1]*rdt end
		return false,rdt - collision[1]*rdt
	else
		return true,rdt
	end
end

function lib.fizzix.expel(self,potential)
	local c,l,r,u,d,maxI
	--if #potential>0 then print("==========================================") end
	for i,v in ipairs(potential) do
		c = self.bounds:intersect(v[1])
		if c then
			l,r,u,d = unpack(self.bounds:relate(v[1]))
			local maxI = math.absMinIndex(l,r,u,d)
			if maxI==1 then
				-- exp. right
				self.bounds.x = self.bounds.x - l
				self.vel.y = 0
			elseif maxI==2 then
				-- exp. left
				self.bounds.x = self.bounds.x + r
				self.vel.y = 0
			elseif maxI==3 then
				-- exp. down
				self.bounds.y = self.bounds.y - u
				self.vel.x = 0
			elseif maxI==4 then
				-- exp. up
				self.bounds.y = self.bounds.y + d
				self.vel.x = 0
			end
		end
	end
end

function lib.fizzix.gravity(self,world,dt)
	-- apply gravity
	self.vel.y = self.vel.y + world.fizzix.grav*dt
end

function lib.fizzix.air(self,world,dt)
	-- apply air resistance
	self.vel = self.vel / (1+world.fizzix.drag*dt)
end

function lib.fizzix.update(self,world,dt)

	local rdt = dt -- remaining delta time
	local blacklist = {}
	local continue = true

	self.onGround = false
	repeat
		local potential = lib.fizzix.gatherPotential(self,world,blacklist,rdt)
		local collision = lib.fizzix.testCollision(self,potential,rdt)
		local stop,rdt = lib.fizzix.react(self,collision,blacklist,rdt)
		--print(self.vel)
	until stop
	local potential = lib.fizzix.gatherPotential(self,world,{},rdt)
	local collision = lib.fizzix.testCollision(self,potential,rdt)
	_,rdt = lib.fizzix.react(self,collision,{},rdt)
	--print(self.vel)

	-- apply remaining movement
	self.bounds.pos = self.bounds.pos + self.vel*rdt
	
	-- fix any odd remaining intersections
	lib.fizzix.expel(self,potential)

	-- apply clamp; makes some people happy
	if math.abs(self.vel.x)<(self.stats and self.stats.clamp or fizzix.clamp) then self.vel.x = 0 end
	if math.abs(self.vel.y)<(self.stats and self.stats.clamp or fizzix.clamp) then self.vel.y = 0 end
end

-- ==========================================
return lib