local plr = {}

plr.layer = 2
plr.bounds = Rec(0,0,1,1)
plr.vel = Vec(0.2,-0.1)
plr.speed = 5
plr.jump = 5
plr.onGround = false
plr.airDamper = 100
plr.accel = 100
plr.fizzix = {
	fric=3
}

local preCollide

function plr.update(self,dt,world,state)
	-- apply controls
	local walking = false
	if love.keyboard.isDown("left") then
		self.vel.x=math.Lerp(dt*self.accel/(self.onGround and 1 or self.airDamper+1),self.vel.x,-self.speed)
		walking = true
	end
	if love.keyboard.isDown("right") then
		self.vel.x=math.Lerp(dt*self.accel/(self.onGround and 1 or self.airDamper+1),self.vel.x,self.speed)
		walking = true
	end

	-- apply gravity
	self.vel.y = self.vel.y + world.fizzix.grav*dt
	-- apply air resistance
	self.vel = self.vel / (1+world.fizzix.drag*dt)

	local surroundings = {} -- broadphase selection
	local tile
	for y = math.floor(self.bounds.y+math.min(0,self.vel.y*dt)),math.ceil(self.bounds.b+math.max(0,self.vel.y*dt)+1) do
		for x = math.floor(self.bounds.x+math.min(0,self.vel.x*dt)),math.ceil(self.bounds.r+math.max(0,self.vel.x*dt)+1) do
			tile = game.getTile(world,x,y)
			--print(math.floor(x+self.bounds.x),math.floor(y+self.bounds.y))
			if tile and tile.properties.solid then
				table.insert(surroundings, {Rec(x,y,1,1),tile})
			end
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
		if not walking then self.vel = self.vel / (1 + (soonest.iv.properties.fric or 1)*self.fizzix.fric*dt) end
		self.bounds.pos = self.bounds.pos + self.vel*(dt-(dt*soonest[1]))
		print(self.vel)
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
		self.vel.y = -self.jump
		self.onGround = false
	end
end

function plr.draw(self,x,y)
	love.graphics.setColor(255,255,255,255)
	love.graphics.rectangle("fill",x,y,self.bounds.w*tileW,self.bounds.h*tileH)
end

return plr