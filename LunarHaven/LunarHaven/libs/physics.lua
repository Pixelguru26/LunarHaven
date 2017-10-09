local lib = {name = "physics"}
Vec=assert(_VECTOR or require("Vec")() or require("lib/Vec")() or require("libs/Vec")(), "Cannot find/use 'Vec.lua', this is a requirement for "..lib.name.." to function!")
Rec=assert(_RECTANGLE or require("Rec")() or require("lib/Rec")() or require("libs/Vec")(), "Cannot find/use 'Rec.lua', this is a requirement for "..lib.name.." to function!")

local exObj = {
	bounds = Rec(0,0,10,10)
	vel = Vec(0,0)
}

function lib.update(objects,dt)
	for i,v in ipairs(objects) do
		for ii,iv in ipairs(objects) do
			if v~=iv then
				lib.collide(v,iv,dt)
			end
		end
	end
end

function lib.collide(obj,tgt,dt)
	local dists = obj.bounds:relate(tgt.bounds)
	local deltadist = obj.vec * dt
	local xin,yin
	if deltadist.x>0 then
		xin = dists[2]/deltadist.x
	else
		xin = -dists[1]/deltadist.x
	end
	if deltadist.y>0 then
		yin = dists[4]/deltadist.y
	else
		yin = -dists[3]/deltadist.y
	end

	--local coll = math.min(xin,yin)

	local dir = 
end

return lib