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
	airDamper = 200, -- scaling down of acceleration while in air
	jump = 4, -- jumping impulse velocity
	speed = 6, -- max walking velocity
}

local preCollide

function plr.update(self,dt,world,state)
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

	local surroundings = {} -- broadphase selection
	local tile
	local broadphase = self.bounds:copy(
		math.min(0,self.vel.x*dt),
		math.min(0,self.vel.y*dt),
		math.max(0,self.vel.x*dt)-math.min(0,self.vel.x*dt),
		math.max(0,self.vel.y*dt)-math.min(0,self.vel.y*dt)
	)
	local minTile = Rec(math.floor(broadphase.x),math.floor(broadphase.y),1,1)
	for space in broadphase:iter(minTile) do
		tile = game.getTile(world,space.x,space.y)
		--print(math.floor(x+self.bounds.x),math.floor(y+self.bounds.y))
		if tile and tile.properties.solid then
			table.insert(surroundings,{Rec(space.x,space.y,1,1),tile})
			--table.insert(self.fizzRects, Rec(space.x,space.y,1,1))
		end
	end

	-- collision data gathering (modified from simplest)
	local potential = {}
	for i,v in ipairs(surroundings) do
		table.insert(potential,{game.sweptCollide(self,v[1],dt)})
		potential[#potential].iv = v[2]
	end

	-- collision sorting
	local soonest = potential[1]
	for i,v in ipairs(potential) do
		if v[1]<soonest[1] then
			soonest = v
		end
	end

	--if soonest then print(self.bounds,soonest["iv"],soonest[1]) end

	if soonest and soonest[1]>=0 and soonest[1]<1 then
		if soonest[2].y==-1 then self.onGround = true end
		self.bounds.pos=self.bounds.pos+self.vel*(soonest[1]*dt)
		self.vel = self.vel * soonest[2].rev.abs
		self.bounds.pos = self.bounds.pos + self.vel*(dt-(dt*soonest[1]))

		if not walking then 
			self.vel = self.vel / (1 + (soonest.iv.properties.fric or 1)*self.stats.fric*dt) -- normal friction
			if self.onGround then 
				self.vel.x = self.vel.x / (1+(soonest.iv.properties.fric or 1)*self.stats.stumble*dt) -- stumble friction
			end
		end
	else
		self.onGround=false
		self.bounds.pos = self.bounds.pos + self.vel*dt
	end
	--print(self.vel)

	-- apply viewPort pos
	state.viewPort.x = math.Lerp(dt*3,state.viewPort.x,(self.bounds.x+self.bounds.w/2)*tileW-love.graphics.getWidth()/2)
	state.viewPort.y = math.Lerp(dt*3,state.viewPort.y,(self.bounds.y+self.bounds.h/2)*tileH-love.graphics.getHeight()/2)
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
end

return plr