if not love.graphics.intersectScissor then
	-- it's a REQUIREMENT.
	-- sadly.
	-- I hate adding this here.
	function love.graphics.intersectScissor(x,y,w,h)
		local ox,oy,ow,oh = love.graphics.getScissor()
		ox,oy,ow,oh = ox or 0,oy or 0,ow or gw(),oh or gh()
		local nx,ny = max(x,ox),max(x,oy)
		local nw,nh = min(x+w,ox+ow)-nx,min(y+h,oy+oh)-ny
		love.graphics.setScissor(nx,ny,nw,nh)
		return nx,ny,nw,nh
	end
end

local function framedRect(rect,topLeft,topRight,bottomLeft,bottomRight,top,left,bottom,right,outside,rep,sx,sy)
	sx = sx or 1
	sy = sy or 1
	if outside then
		local dx = -math.max(topLeft:getWidth()*sx,left:getWidth()*sx,bottomLeft:getWidth()*sx)
		local dy = -math.max(topLeft:getHeight()*sy,top:getHeight()*sy,topRight:getHeight()*sy)
		local dw = -dx + math.max(topRight:getWidth()*sx,right:getWidth()*sx,bottomRight:getWidth()*sx)
		local dh = -dy + math.max(bottomLeft:getWidth()*sy,bottom:getHeight()*sy,bottomRight:getHeight()*sy)
		local outerRect = _RECTANGLE(rect.x+dx,rect.y+dy,rect.w+dw,rect.h+dh);
		if rep then
			local x,y,w,h = love.graphics.getScissor()
			love.graphics.intersectScissor(unpack(outerRect))
			for x=rect.x,rect.r,(top:getWidth()*sx) do
				love.graphics.draw(top,x,rect.y-(top:getHeight()*sy),0,sx,sy)
			end
			for x=rect.x,rect.r,(bottom:getWidth()*sx) do
				love.graphics.draw(bottom,x,rect.b,0,sx,sy)
			end
			for y=rect.y,rect.b,(left:getHeight()*sy) do
				love.graphics.draw(left,rect.x-(left:getWidth()*sx),y,0,sx,sy)
			end
			for y=rect.y,rect.b,(right:getHeight()*sy) do
				love.graphics.draw(right,rect.r,y,0,sx,sy)
			end
			love.graphics.setScissor(x,y,w,h)
		else
			love.graphics.draw(top,rect.x,rect.y-(top:getHeight()*sy),0,rect.w/(top:getWidth()*sx)*sx,sy)
			love.graphics.draw(bottom,rect.x,rect.b,0,rect.w/(bottom:getWidth()*sx)*sx,sy)
			love.graphics.draw(left,rect.x-(left:getWidth()*sx),rect.y,0,sx,rect.h/(left:getHeight()*sy)*sy)
			love.graphics.draw(right,rect.r,rect.y,0,sx,rect.h/(right:getHeight()*sy)*sy)
		end
		love.graphics.draw(topLeft,rect.x-(topLeft:getWidth()*sx),rect.y-(topLeft:getHeight()*sy),0,sx,sy)
		love.graphics.draw(topRight,rect.r,rect.y-(topRight:getHeight()*sy),0,sx,sy)
		love.graphics.draw(bottomLeft,rect.x-(bottomLeft:getWidth()*sx),rect.b,0,sx,sy)
		love.graphics.draw(bottomRight,rect.r,rect.b,0,sx,sy)
	else
		if rep then
			local x,y,w,h = love.graphics.getScissor()
			love.graphics.intersectScissor(unpack(rect))
			local r1 = rect.r-(topRight:getWidth()*sx)
			local r2 = rect.r-(bottomRight:getWidth()*sx)
			local b1 = rect.b-(bottomLeft:getHeight()*sy)
			local b2 = rect.b-(bottomRight:getHeight()*sy)
			for x=rect.x+(topLeft:getWidth()*sx),r1,(top:getWidth()*sx) do
				love.graphics.draw(top,x,rect.y,0,sx,sy)
			end
			for x=rect.x+(bottomLeft:getWidth()*sx),r2,(bottom:getWidth()*sx) do
				love.graphics.draw(bottom,x,rect.b-(bottom:getHeight()*sy),0,sx,sy)
			end
			for y=rect.y+(topLeft:getHeight()*sy),b1,(left:getHeight()*sy) do
				love.graphics.draw(left,rect.x,y,0,sx,sy)
			end
			for y=rect.y+(topLeft:getHeight()*sy),b2,(right:getHeight()*sy) do
				love.graphics.draw(right,rect.r-(right:getWidth()*sx),y,0,sx,sy)
			end
			love.graphics.setScissor(x,y,w,h)
		else
			local w1 = rect.w-(topLeft:getWidth()*sx)-(topRight:getWidth()*sx)
			local w2 = rect.w-(bottomLeft:getWidth()*sx)-(bottomRight:getWidth()*sx)
			local h1 = rect.h-(topLeft:getHeight()*sy)-(bottomLeft:getHeight()*sy)
			local h2 = rect.h-(topRight:getHeight()*sy)-(bottomRight:getHeight()*sy)
			love.graphics.draw(top,rect.x+(topLeft:getWidth()*sx),rect.y,0,w1/(top:getWidth()*sx)*sx,sy)
			love.graphics.draw(bottom,rect.x+(bottomLeft:getWidth()*sx),rect.b-(bottom:getHeight()*sy),0,w2/(bottom:getWidth()*sx)*sx,sy)
			love.graphics.draw(left,rect.x,rect.y+(topLeft:getHeight()*sy),0,sx,h1/(left:getHeight()*sy)*sy)
			love.graphics.draw(right,rect.r-(right:getWidth()*sx),rect.y+(bottomRight:getHeight()*sy),0,sx,h2/(right:getHeight()*sy)*sy)
		end
		love.graphics.draw(topLeft,rect.x,rect.y,0,sx,sy)
		love.graphics.draw(topRight,rect.r-(topRight:getWidth()*sx),rect.y,0,sx,sy)
		love.graphics.draw(bottomLeft,rect.x,rect.b-(bottomLeft:getHeight()*sy),0,sx,sy)
		love.graphics.draw(bottomRight,rect.r-(bottomRight:getWidth()*sx),rect.b-(bottomRight:getHeight()*sy),0,sx,sy)
	end
end

return framedRect