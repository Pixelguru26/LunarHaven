local lib = {}

local rgb2hex = function (rgb)
	local hexadecimal = '#'
	for key = 1, #rgb do
	    local value = rgb[key] 
		local hex = ''
		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex			
		end
		if(string.len(hex) == 0)then
			hex = '00'
		elseif(string.len(hex) == 1)then
			hex = '0' .. hex
		end
		hexadecimal = hexadecimal .. hex
	end
	return hexadecimal
end

function lib.palette(...)
	local args = {...}
	if type(args[1])=="userdata" then
		-- extract a palette from the image
		local img=args[1]:getData()
		args[1]=nil -- recycling args' table!
		-- left to right, top to bottom, going over two rows of pixels at a time; 
		-- top row of each defines keys, bottom row defines resulting colors.
		for y=0,img:getHeight()-1,2 do
			for x=0,img:getWidth()-1 do
				table.insert(args,{img:getPixel(x,y+1)})
				local r,g,b,a = img:getPixel(x,y)
				args[rgb2hex({r,g,b,a})]=args[#args]
			end
		end
		return args
	end
end

function lib.applyPalette(img,palette)
	for k,v in pairs(palette) do
		print(k.." : "..v[1]..","..v[2]..","..v[3]..","..v[4])
	end
	local data = img:getData()
	for x=0,data:getWidth()-1 do
		for y=0,data:getHeight()-1 do
			local r,g,b,a = data:getPixel(x,y)
			local id = rgb2hex({r,g,b,a})
			if palette[id] then
				data:setPixel(x,y,unpack(palette[id]))
			end
		end
	end
	return love.graphics.newImage(data)
end


return lib