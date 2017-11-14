local lib = {}

function lib.sweptCollide(v,iv,dt)
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
function lib.gatherPotential(self,world,blacklist,rdt)
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
	broadphase:del()
	minTile:del()
	return surroundings
end

function lib.testCollision(self,potential,rdt)
	local soonest = nil
	for i,v in ipairs(potential) do
		local coll = {lib.sweptCollide(self,v[1],rdt)} -- collision data
		coll.iv = v[2] -- not the most elegant way to store the original tile, but it works.
		-- collision "sorting"
		if soonest and soonest[1]<coll[1] then
			soonest:del()
			soonest = coll
		elseif not soonest then
			soonest = coll
		else
			v[1]:del()
		end
	end
	return soonest
end

function lib.react(self,collision,blacklist,rdt)
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

function lib.expel(self,potential)
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

function lib.gravity(self,world,dt)
	-- apply gravity
	self.vel.y = self.vel.y + world.fizzix.grav*dt
end

function lib.air(self,world,dt)
	-- apply air resistance
	self.vel = self.vel / (1+world.fizzix.drag*dt)
end

function lib.update(self,world,dt)

	local rdt = dt -- remaining delta time
	local blacklist = {}
	local continue = true

	self.onGround = false
	repeat
		local potential = lib.gatherPotential(self,world,blacklist,rdt)
		local collision = lib.testCollision(self,potential,rdt)
		local stop,rdt = lib.react(self,collision,blacklist,rdt)
		--print(self.vel)
	until stop
	local potential = lib.gatherPotential(self,world,{},rdt)
	local collision = lib.testCollision(self,potential,rdt)
	_,rdt = lib.react(self,collision,{},rdt)
	--print(self.vel)

	-- apply remaining movement
	self.bounds.pos = self.bounds.pos + self.vel*rdt
	
	-- fix any odd remaining intersections
	lib.expel(self,potential)

	-- apply clamp; makes some people happy
	if math.abs(self.vel.x)<(self.stats and self.stats.clamp or fizzix.clamp) then self.vel.x = 0 end
	if math.abs(self.vel.y)<(self.stats and self.stats.clamp or fizzix.clamp) then self.vel.y = 0 end
end

return lib