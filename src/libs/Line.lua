local lib={name="Line"}
local Vec=assert(_VECTOR or require("Vec")() or require("lib/Vec")() or require("libs/Vec")(), "Cannot find/use 'Vec.lua', this is a requirement for "..lib.name.." to function!")

local _LINE = {Vec(0,0),Vec(0,0),_CACHE={C=0}}
local _CACHE = _LINE._CACHE
_LINE.aliases = {}
_LINE.meta = {}

-- ========================================== Utils

local function min(a,b)
	return a<b and a or b
end
local function max(a,b)
	return a>b and b or a
end
local function lerp(v,a,b)
	return a+v*(b-a)
end

-- ========================================== Aliases

_LINE.aliases.a=1
_LINE.aliases.A=1
_LINE.aliases.b=2
_LINE.aliases.B=2
function _LINE.aliases.x(t,v)
	if v then
		min(a,b).x = v
	else
		return min(a,b).x
	end
end
_LINE.aliases.x0 = _LINE.aliases.x
function _LINE.aliases.y(t,v)
	if v then
		min(a,b).y = v
	else
		return min(a,b).y
	end
end
_LINE.aliases.y0 = _LINE.aliases.y

function _LINE.aliases.x1(t,v)
	if v then
		max(a,b).x = v
	else
		return max(a,b).x
	end
end
function _LINE.aliases.y1(t,v)
	if v then
		max(a,b).y = v
	else
		return max(a,b).y
	end
end

function _LINE.aliases.dx(t,v)
	if v then
		t.b.x = t.a.x+v
	else
		return t.b.x-t.a.x
	end
end
_LINE.aliases.w = _LINE.aliases.dx
function _LINE.aliases.dy(t,v)
	if v then
		t.b.y = t.a.y+v
	else
		return t.b.y-t.a.y
	end
end
_LINE.aliases.h = _LINE.aliases.dy
function _LINE.aliases.slope(t,v)
	return t.dy/d.dx
end

-- ========================================== Methods

function _LINE.solveY(self,x)
	return self.slope*x+self.a.y
end
function _LINE.solveX(self,y)
	return 1/self.slope*y+self.a.x
end
function _LINE.unpack(self)
	return self.a.x,self.a.y,self.b.x,self.b.y
end

function _LINE.del(self)
	table.insert(_CACHE,self)
	_CACHE.C = _CACHE.C + 1
	return self
end

-- ========================================== Mechanics

function _LINE.__index(t,k)
	if _LINE.aliases[k] then
		if type(_LINE.aliases[k])~="function" then
			return t[_LINE.aliases[k]]
		else
			return _LINE.aliases(t)
		end
	else
		return _LINE[k]
	end
end
function _LINE.__newindex(t,k,v)

end

function _LINE.meta.__call(t,x0,y0,x1,y1)
	local v
	if _CACHE.C>0 then
		v=table.remove(_CACHE,_CACHE.C)
		_CACHE.C = _CACHE.C-1
	else
		v = {}
	end
	v[1] = Vec(x0,y0)
	v[2] = Vec(x1,y1)
	return setmetatable(v,_LINE)
end

setmetatable(_LINE,_LINE.meta)

local function ret(...)
	local args={...}
	for i,v in ipairs(args) do
		if type(v)=='string' then
			_G[v]=_LINE
		else
			v=_LINE
		end
	end
	return _LINE
end
return ret