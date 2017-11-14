local lib = {}

_CONTROLS = _CONTROLS or {}

function lib.new(k,...)
	if not _CONTROLS[k] then 
		_CONTROLS[k] = {}
	end
	for i,v in ipairs({...}) do
		_CONTROLS[k][v]=true
	end
end
function lib.remove(k,...)
	local queue = {}
	for i,v in ipairs({...}) do
		_CONTROLS[k][v]=nil
	end
end
function lib.isDown(k)
	for k,v in pairs(_CONTROLS[k]) do
		if love.keyboard.isDown(k) then
			return true
		end
		if love.mouse.isDown(k) then
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