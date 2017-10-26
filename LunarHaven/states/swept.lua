local state = {}

state.rec1 = {
	bounds = Rec(200,0,50,50),
	vel = Vec(0,0)
}
state.rec2 = Rec(100,200,400,50)

function state.update(dt)
	local v = state.rec1

	-- apply control
	if love.keyboard.isDown("left") then
		v.vel.x = v.vel.x - 200*dt
	end
	if love.keyboard.isDown("right") then
		v.vel.x = v.vel.x + 200*dt
	end
	if love.keyboard.isDown("up") then
		v.vel.y = v.vel.y - 200*dt
	end
	if love.keyboard.isDown("down") then
		v.vel.y = v.vel.y + 200*dt
	end
	-- apply gravity
	--v.vel.y = v.vel.y + 98*dt

	local t,n = state.collide(v,state.rec2,dt)
	v.bounds.pos = t and v.bounds.pos+v.vel*t*dt or v.bounds.pos+v.vel*dt
	v.vel = n and n*100 or v.vel
end

function state.draw()
	local rec1,rec2 = state.rec1.bounds,state.rec2
	love.graphics.rectangle("line",rec1.x,rec1.y,rec1.w,rec1.h)
	love.graphics.rectangle("line",rec2.x,rec2.y,rec2.w,rec2.h)
end

function state.collide(v,iv,dt)
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

	if love.keyboard.isDown(" ") then
		print("VEL: ",string.sub(tostring(v.vel.x),1,4),string.sub(tostring(v.vel.y),1,4),string.sub(tostring(dt),1,4))
		print("TME: ",entryTime)
	end

	if entryTime>exitTime or xEntry>=1 or yEntry>=1 or (xEntry<0 and yEntry<0) then
		--if love.keyboard.isDown(" ") then
		--	print(entryTime,exitTime)
		--end
		return nil
	end
	--if xEntry < 0 then
	--	if not (v.bounds.x > iv.r and v.bounds.r > iv.x) then return 1.0 end
	--end
	--if yEntry < 0 then
	--	if not (v.bounds.y > iv.b and v.bounds.b > iv.y) then return 1.0 end
	--end

	--print(entryTime)
	--if entryTime<1 then 
	--	print("COLLISION",xEntry,yEntry,entryTime)
	--end
	if yEntry>xEntry then
		-- y axis entry
		if v.vel.y>0 then
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

return state