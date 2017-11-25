function framedRect(rect,topLeft,topRight,bottomLeft,bottomRight,top,left,bottom,right,outside,rep)
	if outside then
		if rep then
			for x=rect.x,rect.r-top:getWidth(),top:getWidth() do
				love.graphics.draw(top,x,rect.y-top:getHeight())
			end
			for x=rect.x,rect.r-bottom:getWidth(),bottom:getWidth() do
				love.graphics.draw(bottom,x,rect.b)
			end
			for y=rect.y,rect.b-left:getHeight(),left:getHeight() do
				love.graphics.draw(left,rect.x-left:getWidth(),y)
			end
			for y=rect.y,rect.b-right:getHeight(),right:getHeight() do
				love.graphics.draw(right,rect.r,y)
			end
		else
			love.graphics.draw(top,rect.x,rect.y-top:getHeight(),0,rect.w/top:getWidth(),1)
			love.graphics.draw(bottom,rect.x,rect.b,0,rect.w/bottom:getWidth(),1)
			love.graphics.draw(left,rect.x-left:getWidth(),rect.y,0,1,rect.h/left:getHeight())
			love.graphics.draw(right,rect.r,rect.y,0,1,rect.h/right:getHeight())
		end
		love.graphics.draw(topLeft,rect.x-topLeft:getWidth(),rect.y-topLeft:getHeight())
		love.graphics.draw(topRight,rect.r,rect.y-topRight:getHeight())
		love.graphics.draw(bottomLeft,rect.x-bottomLeft:getWidth(),rect.b)
		love.graphics.draw(bottomRight,rect.r,rect.b)
	else
		if rep then
			local r1 = rect.r-topRight:getWidth()-top:getWidth()
			local r2 = rect.r-bottomRight:getWidth()-bottom:getWidth()
			local b1 = rect.b-bottomLeft:getHeight()-left:getHeight()
			local b2 = rect.b-bottomRight:getHeight()-right:getHeight()
			for x=rect.x+topLeft:getWidth(),r1,top:getWidth() do
				love.graphics.draw(top,x,rect.y)
			end
			for x=rect.x+bottomLeft:getWidth(),r2,bottom:getWidth() do
				love.graphics.draw(bottom,x,rect.b-bottom:getHeight())
			end
			for y=rect.y+topLeft:getHeight(),b1,left:getHeight() do
				love.graphics.draw(left,rect.x,y)
			end
			for y=rect.y+topLeft:getHeight(),b2,right:getHeight() do
				love.graphics.draw(right,rect.r-right:getWidth(),y)
			end
		else
			local w1 = rect.w-topLeft:getWidth()-topRight:getWidth()
			local w2 = rect.w-bottomLeft:getWidth()-bottomRight:getWidth()
			local h1 = rect.h-topLeft:getHeight()-bottomLeft:getHeight()
			local h2 = rect.h-topRight:getHeight()-bottomRight:getHeight()
			love.graphics.draw(top,rect.x+topLeft:getWidth(),rect.y,0,w1/top:getWidth(),1)
			love.graphics.draw(bottom,rect.x+bottomLeft:getWidth(),rect.b-bottom:getHeight(),0,w2/bottom:getWidth(),1)
			love.graphics.draw(left,rect.x,rect.y+topLeft:getHeight(),0,1,h1/left:getHeight())
			love.graphics.draw(right,rect.r-right:getWidth(),rect.y+bottomRight:getHeight(),0,1,h2/right:getHeight())
		end
		love.graphics.draw(topLeft,rect.x,rect.y)
		love.graphics.draw(topRight,rect.r-topRight:getWidth(),rect.y)
		love.graphics.draw(bottomLeft,rect.x,rect.b-bottomLeft:getHeight())
		love.graphics.draw(bottomRight,rect.r-bottomRight:getWidth(),rect.b-bottomRight:getHeight())
	end
end

return framedRect