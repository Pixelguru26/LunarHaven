local lume = require("libs/lume")

local plr = {}

plr.layer = 2
plr.bounds = Rec(0,0,1,1)
plr.vel = Vec(0.2,-0.1)
plr.onGround = false
plr.stats = {
	fric = 3, -- generic physics friction
	clamp = 0.0005, -- minimum velocity
	stumble = 10, -- friction value for walking
	accel = 50, -- walking acceleration
	airDamper = 600, -- scaling down of acceleration while in air
	jump = 4, -- jumping impulse velocity
	speed = 8, -- max walking velocity
}

plr.fizzRects = {}

local preCollide

function plr.update(self,dt,world,state)
	self.fizzRects = {}
	-- apply controls; messy, but essentially just clamps *walking* acceleration at walking speed limit (self.stats.speed)
	local walking = false
	if love.keyboard.isDown("left") then
		self.vel.x = self.vel.x - math.Limit(
			self.stats.accel / (self.onGround and 1 or 1+self.stats.airDamper),
			0,
			math.Limit(self.stats.speed-math.abs(self.vel.x),0,self.stats.speed
		))

		walking = true
	end
	if love.keyboard.isDown("right") then
		self.vel.x = self.vel.x + math.Limit(
			self.stats.accel / (self.onGround and 1 or 1+self.stats.airDamper),
			0,
			math.Limit(self.stats.speed-math.abs(self.vel.x),0,self.stats.speed
		))

		walking = true
	end

	-- apply gravity
	self.vel.y = self.vel.y + world.fizzix.grav*dt
	-- apply air resistance
	self.vel = self.vel / (1+world.fizzix.drag*dt)
	-- apply clamp; makes some people happy
	if math.abs(self.vel.x)<self.stats.clamp then self.vel.x = 0 end
	if math.abs(self.vel.y)<self.stats.clamp then self.vel.y = 0 end

	local rdt = dt -- remaining delta time
	local blacklist = {}
	local continue = true

	self.onGround = false
	repeat
		local potential = self:gatherPotential(world,blacklist,rdt)
		local collision = self:testCollision(potential,rdt)
		local stop,rdt = self:react(collision,blacklist,rdt)
	until stop

	self.bounds.pos = self.bounds.pos + self.vel*rdt

	-- apply viewPort pos
	state.viewPort.x = math.Lerp(dt*10,state.viewPort.x,(self.bounds.x+self.bounds.w/2)*tileW-love.graphics.getWidth()/2)
	state.viewPort.y = math.Lerp(dt*10,state.viewPort.y,(self.bounds.y+self.bounds.h/2)*tileH-love.graphics.getHeight()/2)
end

function plr.keypressed(self,key)
	if key=="up" and self.onGround then
		self.vel.y = -self.stats.jump
		self.onGround = false
	end
end

function plr.draw(self,x,y)
	love.graphics.setColor(255,255,255,255)
	love.graphics.rectangle("fill",x,y,self.bounds.w*tileW,self.bounds.h*tileH)
	for i,v in ipairs(self.fizzRects) do
		love.graphics.rectangle("line",v.x*tileW-state.viewPort.x,v.y*tileH-state.viewPort.y,v.w*tileW,v.h*tileH)
	end
end

function plr.gatherPotential(self,world,blacklist,rdt)
	local surroundings = {}
	local broadphase = self.bounds:copy(
		math.min(0,self.vel.x*rdt),
		math.min(0,self.vel.y*rdt),
		math.max(0,self.vel.x*rdt)-math.min(0,self.vel.x*rdt),
		math.max(0,self.vel.y*rdt)-math.min(0,self.vel.y*rdt)
	)
	local minTile = Rec(math.floor(broadphase.x),math.floor(broadphase.y),1,1)
	for space in broadphase:iter(minTile) do
		tile = game.getTile(world,space.x,space.y)
		--print(math.floor(x+self.bounds.x),math.floor(y+self.bounds.y))
		if tile and tile.properties.solid then
			local v = {Rec(space.x,space.y,1,1),tile}
			local allowed = true -- blacklist implementation
			for ii,iv in ipairs(blacklist) do
				allowed = allowed and v==iv
			end
			if allowed then table.insert(surroundings,v) end
			--table.insert(self.fizzRects, Rec(space.x,space.y,1,1))
		end
	end
	return surroundings
end

function plr.testCollision(self,potential,rdt)
	local soonest = nil
	for i,v in ipairs(potential) do
		local coll = {game.sweptCollide(self,v[1],rdt)} -- collision data
		coll.iv = v[2] -- collision "sorting"
		if soonest and soonest[1]<coll[1] then
			soonest = coll
		elseif not soonest then
			soonest = coll
		end
	end
	return soonest
end

function plr.react(self,collision,blacklist,rdt)
	if collision and collision[1]>=0 and collision[1]<1 then
		print("collision")
		if collision[2].y==-1 then self.onGround = true end
		self.bounds.pos=self.bounds.pos+self.vel*(collision[1]*rdt) -- apply collision snapping
		self.vel = self.vel * collision[2].rev.abs -- apply collision to velocity

		if not walking then 
			self.vel = self.vel / (1 + (collision.iv.properties.fric or 1)*self.stats.fric*rdt) -- normal friction
			if self.onGround then 
				self.vel.x = self.vel.x / (1+(collision.iv.properties.fric or 1)*self.stats.stumble*rdt) -- stumble friction
			end
		end

		table.insert(blacklist,collision.iv)
		return false,rdt - collision[1]*rdt
	else
		return true
	end
end

return plr