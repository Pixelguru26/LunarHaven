local lib={name="Rec"}
local Vec
Vec=assert(_VECTOR or require("Vec")() or require("lib/Vec")() or require("libs/Vec")(), "Cannot find/use 'Vec.lua', this is a requirement for "..lib.name.." to function!")

local _RECTANGLE={0,0,0,0,type="rectangle",_CACHE={}}
local _CACHE = _RECTANGLE._CACHE

_RECTANGLE.x=1
_RECTANGLE.X=1
_RECTANGLE.left=1
_RECTANGLE.Left=1
_RECTANGLE.LEFT=1
_RECTANGLE.y=2
_RECTANGLE.Y=2
_RECTANGLE.top=2
_RECTANGLE.Top=2
_RECTANGLE.TOP=2
_RECTANGLE.w=3
_RECTANGLE.W=3
_RECTANGLE.width=3
_RECTANGLE.Width=3
_RECTANGLE.WIDTH=3
_RECTANGLE.h=4
_RECTANGLE.H=4
_RECTANGLE.height=4
_RECTANGLE.Height=4
_RECTANGLE.HEIGHT=4

_RECTANGLE.meta={}
_RECTANGLE.data={}
-- horiz
	function _RECTANGLE.l(v,iv)
		if iv then
			v.x=iv
		end
		return v.x
	end
	_RECTANGLE.L=_RECTANGLE.l
	function _RECTANGLE.r(v,iv)
		if iv then
			v.x=iv-v.w
		end
		return v.x+v.w
	end
	_RECTANGLE.R=_RECTANGLE.r
-- vert
	function _RECTANGLE.t(v,iv)
		if iv then
			v.y=iv.y
		end
		return v.y
	end
	_RECTANGLE.T=_RECTANGLE.t
	function _RECTANGLE.b(v,iv)
		if iv then
			v.y=iv-v.h
		end
		return v.y+v.h
	end
	_RECTANGLE.B=_RECTANGLE.b
-- mid
	function _RECTANGLE.mx(v,iv)
		if iv then
			v.x=iv-v.w/2
		end
		return v.x+v.w/2
	end
	_RECTANGLE.MX=_RECTANGLE.mx
	function _RECTANGLE.my(v,iv)
		if iv then
			v.y=iv-v.h/2
		end
		return v.y+v.h/2
	end
	_RECTANGLE.MY=_RECTANGLE.my
-- corners
	function _RECTANGLE.pos(v,iv)
		if iv then
			v.x=iv.x
			v.y=iv.y
		else
			return Vec(v.x,v.y)
		end
	end
	function _RECTANGLE.pos1(v,iv)
		if iv then
			v.x=iv.x
			v.y=iv.y
		end
		return Vec(v.x,v.y)
	end
	function _RECTANGLE.pos2(v,iv)
		if iv then
			v.r=iv.x
			v.y=iv.y
		end
		return Vec(v.r,v.y)
	end
	function _RECTANGLE.pos3(v,iv)
		if iv then
			v.x=iv.x
			v.b=iv.y
		end
		return Vec(v.x,v.b)
	end
	function _RECTANGLE.pos4(v,iv)
		if iv then
			v.r=iv.x
			v.b=iv.y
		end
		return Vec(v.r,v.b)
	end
	function _RECTANGLE.pos5(v,iv)
		if iv then
			v.mx=iv.x
			v.my=iv.y
		end
		return Vec(v.mx,v.my)
	end
-- other??
	function _RECTANGLE.dims(v,iv)
		if iv then
			v.w=iv.x
			v.h=iv.y
		end
		return Vec(v.w,v.h)
	end
	-- end of properties
		for k,v in pairs(_RECTANGLE) do
			_RECTANGLE.data[k]='property'
		end
	-- ==========================================
	_RECTANGLE.type="rectangle"
	function _RECTANGLE.intersect(v,iv)
		return(	v.r>=iv.l and
				v.l<=iv.r and
				v.t<=iv.b and
				v.b>=iv.t)
	end
	function _RECTANGLE.fullIntersect(v,iv)
		return v:intersect(iv),v:relate(iv)
	end
	function _RECTANGLE.relate(v,iv)
		-- ALL DISTANCES POSITIVE
		local dists={
			v.l-iv.r, -- distance to the left
			iv.l-v.r, -- distance to the right
			v.t-iv.b, -- distance up
			iv.t-v.b -- distance down
		}
		return dists
	end
	function _RECTANGLE.fit(v,iv,copy)
		if copy then
			local r = v:copy()
			r.x = math.min(math.max(r.x,iv.x),iv.r-r.w)
			r.y = math.min(math.max(r.y,iv.y),iv.b-r.h)
			return r
		else
			v.x = math.min(math.max(v.x,iv.x),iv.r-v.w)
			v.y = math.min(math.max(v.y,iv.y),iv.b-v.h)
			return v
		end
	end
	function _RECTANGLE.copy(v,dx,dy,dw,dh,mod)
		if mod then
			for k,v in pairs(v) do
				mod[k] = v
			end
		end
		dx=dx or 0
		dy=dy or 0
		dw=dw or 0
		dh=dh or 0
		return _RECTANGLE(v.x+dx,v.y+dy,v.w+dw,v.h+dh,mod)
	end
	function _RECTANGLE.multiply(v,val)
		return _RECTANGLE(v.x*val,v.y*val,v.w*val,v.h*val)
	end

	local function iter(self,other)
		if other.r<self.r then
			other.x = other.x + other.w
		elseif other.b<self.b then
			other.x = other._ITERSTARTX
			other.y = other.y + other.h
		else
			return nil
		end
		return other,other
	end
	function _RECTANGLE.iter(self,other)
		other._ITERSTARTX = other.x
		other.x = other.x - other.w
		return iter,self,other
	end

function _RECTANGLE.__index(t,k,v,...)
	local args={...}
	if v then
		if type(_RECTANGLE[k])=='function' and _RECTANGLE.data[k] then
			return _RECTANGLE[k](t,v,unpack(args))
		elseif _RECTANGLE[k] then
			t[_RECTANGLE[k]]=v
		else
			return nil
		end
	else
		if type(_RECTANGLE[k])=='function' and _RECTANGLE.data[k] then
			return _RECTANGLE[k](t)
		elseif _RECTANGLE[k] and _RECTANGLE.data[k] then
			return t[_RECTANGLE[k]] or _RECTANGLE[k]
		elseif _RECTANGLE[k] then
			return _RECTANGLE[k]
		else
			return nil
		end
	end
end

function _RECTANGLE.__newindex(t,k,v,...)
	local args={...}
	if v then
		if type(_RECTANGLE[k])=='function' and _RECTANGLE.data[k] then
			return _RECTANGLE[k](t,v,unpack(args))
		elseif _RECTANGLE[k] and _RECTANGLE.data[k] then
			t[_RECTANGLE[k]]=v
		else
			rawset(t,k,v)
		end
	else
		if type(_RECTANGLE[k])=='function' and _RECTANGLE.data[k] then
			return _RECTANGLE[k](t)
		elseif _RECTANGLE[k] and _RECTANGLE.data[k] then
			return t[_RECTANGLE[k]] or _RECTANGLE[k]
		elseif _RECTANGLE[k] then
			return _RECTANGLE[k]
		else
			return rawget(t,k)
		end
	end
end

function _RECTANGLE.__tostring(v)
	local ret={'[',tostring(v.pos1),',',tostring(v.dims),']'}
	return table.concat(ret)
end
function _RECTANGLE.__eq(a,b)
	return a.pos1==b.pos1 and a.pos4==b.pos4
end

function _RECTANGLE.meta.__call(t,x,y,w,h,v)
	v = v or table.remove(_CACHE,#_CACHE) or {}
	v.x = x
	v.y = y
	v.w = w
	v.h = h
	return setmetatable(v,_RECTANGLE)
end

function _RECTANGLE.del(v)
	table.insert(_CACHE,v)
end


setmetatable(_RECTANGLE,_RECTANGLE.meta)

local function ret(...)
	local args={...}
	for i,v in ipairs(args) do
		if type(v)=='string' then
			_G[v]=_RECTANGLE
		else
			v=_RECTANGLE
		end
	end
	return _RECTANGLE
end
return ret