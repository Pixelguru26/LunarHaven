local lume = require("libs/lume")
local game = game
local fizzix = game.fizzix
local controls = game.control

local plr = {layer = 2}



plr.fizzRects = {}

function plr.load(self)
	controls.new("mvLeft","left","a")
	controls.new("mvRight","right","d")
	controls.new("jump","space","up","w")
	plr.bounds = Rec(0,0,.95,1)
	plr.vel = Vec(0.2,-0.1)
	plr.onGround = false
	plr.stats = {
		fric = 3, -- generic physics friction
		clamp = fizzix.clamp, -- minimum velocity
		stumble = 10, -- friction value for walking
		accel = 10, -- walking acceleration
		airDamper = 100, -- scaling down of acceleration while in air
		jump = 4, -- jumping impulse velocity
		speed = 8, -- max walking velocity
		mass = 1
	}
end

function plr.update(self,dt,world,state)
	-- self.fizzRects = {}
	-- apply controls; messy, but essentially just clamps *walking* acceleration at walking speed limit (self.stats.speed)
	local walking = false
	if controls.isDown("mvLeft") then
		self.vel.x = self.vel.x - math.Limit(
			self.stats.accel / (self.onGround and 1 or 1+self.stats.airDamper),
			0,
			math.Limit(self.stats.speed-math.abs(self.vel.x),0,self.stats.speed
		))
		walking = true
	end
	if controls.isDown("mvRight") then
		self.vel.x = self.vel.x + math.Limit(
			self.stats.accel / (self.onGround and 1 or 1+self.stats.airDamper),
			0,
			math.Limit(self.stats.speed-math.abs(self.vel.x),0,self.stats.speed
		))

		walking = true
	end

	fizzix.gravity(self,world,dt)
	fizzix.air(self,world,dt)
	fizzix.update(self,world,dt)

	-- apply viewPort pos
	state.viewPort.x = math.Lerp(dt*camSpeed,state.viewPort.x,(self.bounds.x+self.bounds.w/2)*tileW-love.graphics.getWidth()/2)
	state.viewPort.y = math.Lerp(dt*camSpeed,state.viewPort.y,(self.bounds.y+self.bounds.h/2)*tileH-love.graphics.getHeight()/2)
end

function plr.keypressed(self,key)
	if controls.isIn("jump",key) and self.onGround then
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

return plr