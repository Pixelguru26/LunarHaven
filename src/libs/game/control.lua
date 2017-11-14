local lib = {}

_CONTROLS = _CONTROLS or {}

function lib.new(k,...)
	if _CONTROLS[k] then
		for i,v in ipairs({...}) do
			_CONTROLS[k][v]=true
		end
	else
		_CONTROLS[k] = {...}
	end
end
function lib.remove(k,...)
	local queue = {}
	for i,v in ipairs({...}) do
		_CONTROLS[k][v]=nil
	end
end
function lib.isDown(k)
	for i,v in ipairs(_CONTROLS[k]) do
		if love.keyboard.isDown(v) then
			return true
		end
		if love.mouse.isDown(v) then
			return true
		end
	end
	return false
end
function lib.isIn(k,v)
	if _CONTROLS[k] then
		return _CONTROLS[k][v]
	end
	return false
end

return lib