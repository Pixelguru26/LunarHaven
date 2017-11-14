local UI = {hotbar = {scroll=0,selIndex=1}}

function UI.load()
	UI.gradientShader = love.graphics.newShader("stockData/shaders/gradient.fs")
	UI.img = {
		default=love.graphics.newImage("stockData/defaultBlock.png"),
		error=love.graphics.newImage("stockData/errorBlock.png"),
		metal=love.graphics.newImage("stockData/metalTexture.png"),
		noise=love.graphics.newImage("stockData/noiseTexture.png"),
		conduitsLeft=love.graphics.newImage("stockData/conduitOverlayLeft.png"),
		conduits=love.graphics.newImage("stockData/conduitOverlay.png"),
		conduitsRight=love.graphics.newImage("stockData/conduitOverlayRight.png")
	}

	UI.resize(gw(),gh())
end

local last = Vec(0,0)
local placedLast = false
function UI.update(dt)
	local ox = math.floor((love.mouse.getX()+state.viewPort.x)/tileW) -- world x
	local oy = math.floor((love.mouse.getY()+state.viewPort.y)/tileH) -- world y

	if love.mouse.isDown('l') and not Vec(love.mouse.getX(),love.mouse.getY()):isWithinRec(Rec(gw()-ui.hotBarWidth*gw(),gh()*ui.hotBarMargin,UI.hotBarCanv:getWidth(),UI.hotBarCanv:getHeight())) then
		if last then
			UI.placeBlock(UI.hotbar.selIndex,ox,oy)
			local place = last:copy()
			local pos = Vec(ox,oy)
			while place:dist(pos)>0 do
				place.x = (place.x<pos.x and place.x+1) or (place.x>pos.x and place.x-1) or place.x
				place.y = (place.y<pos.y and place.y+1) or (place.y>pos.y and place.y-1) or place.y
				UI.placeBlock(UI.hotbar.selIndex,place.x,place.y)
			end
			placedLast=true
		else
			UI.placeBlock(UI.hotbar.selIndex,ox,oy)
			placedLast=true
		end
	else
		placedLast = false
	end
	last = Vec(ox,oy)
end

function UI.draw()
	love.graphics.reset()

	-- hotbar
	love.graphics.draw(UI.hotBarCanv,gw()-ui.hotBarWidth*gw(),gh()*ui.hotBarMargin)
	-- draw items
	local hw,hh = UI.hotBarCanv:getWidth(),UI.hotBarCanv:getHeight()
	local xi = gw()-(3/4*ui.hotBarWidth*gw()) -- left
	local yi = gh()*ui.hotBarMargin+hw*ui.hotBarTop -- top
	local w = 3/4*hw -- width of the hotbar itself
	local h = hh-hw*ui.hotBarTop -- height of the item area
	local di = hw/2 -- unified dimension of item slot

	love.graphics.setScissor(xi,yi,w,h)
	for y = 0,8 do
		local xPos = xi+(w/2-di/2)
		local yPos = yi+y*di+y*ui.hotBarGap*hw-UI.hotbar.scroll*(di+ui.hotBarGap*hw)+ui.hotBarGap*hw/2
		love.graphics.setColor(85,255,255,y+1==UI.hotbar.selIndex and 255 or 255/2)
		love.graphics.rectangle("fill",xPos,yPos,di,di)
		love.graphics.setColor(255,255,255,255)
		if UI.hotbar[y+1] and UI.hotbar[y+1].frames then
			local img = UI.hotbar[y+1].frames.tile or UI.hotbar[y+1].frames.icon or UI.img.error
			local w = di-di*ui.hotBarPadding*2
			love.graphics.draw(img,xPos+ui.hotBarPadding*di,yPos+ui.hotBarPadding*di,0,w/img:getWidth(),w/img:getWidth())
		end
		love.graphics.print(tostring(y+1),xPos,yPos)
	end

	love.graphics.setScissor()

	--love.graphics.rectangle("fill",gw()-(3/4*ui.hotBarWidth*gw()),gh()*ui.hotBarMargin+UI.hotBarCanv:getWidth()*ui.hotBarTop,3/4*UI.hotBarCanv:getWidth(),UI.hotBarCanv:getHeight()-UI.hotBarCanv:getWidth()*ui.hotBarTop)
end

function UI.resize(w,h)
	UI.hotBarCanv = love.graphics.newCanvas(w*ui.hotBarWidth,h-ui.hotBarMargin*h*2)
	UI.reDraw(w,h)
end

function UI.mousepressed(x,y,b)
	local pos = Vec(x,y)
	if pos:isWithinRec(Rec(gw()-ui.hotBarWidth*gw(),gh()*ui.hotBarMargin,UI.hotBarCanv:getWidth(),UI.hotBarCanv:getHeight())) then
		if b=="wu" or b=="wl" then
			UI.hotbar.scroll = math.max(UI.hotbar.scroll-0.5,0)
		elseif b=="wd" or b=="wr" then
			UI.hotbar.scroll = math.min(UI.hotbar.scroll+0.5,9-(UI.hotBarCanv:getHeight()-UI.hotBarCanv:getWidth()*ui.hotBarTop)/(UI.hotBarCanv:getWidth()/2+UI.hotBarCanv:getWidth()*ui.hotBarGap))
		else
			local hw,hh = UI.hotBarCanv:getWidth(),UI.hotBarCanv:getHeight()
			local xi = gw()-(3/4*ui.hotBarWidth*gw()) -- left
			local yi = gh()*ui.hotBarMargin+hw*ui.hotBarTop -- top
			local w = 3/4*hw -- width of the hotbar itself
			local h = hh-hw*ui.hotBarTop -- height of the item area
			local di = hw/2 -- unified dimension of item slot

			if pos:isWithinRec(Rec(xi+(w/2-di/2),yi,di,h)) then
				if b=='l' then
					local index = math.floor((y-yi+UI.hotbar.scroll*(di+ui.hotBarGap*hw))/(di+ui.hotBarGap*hw))+1
					UI.hotbar.selIndex = index
				end
			end
		end
	else
		local ox = math.floor((x+state.viewPort.x)/tileW) -- world x
		local oy = math.floor((y+state.viewPort.y)/tileH) -- world y
		if b=="l" then
			UI.placeBlock(UI.hotbar.selIndex,ox,oy)
		elseif b=="wu" or b=="wl" then
			UI.hotbar.selIndex=math.Limit(UI.hotbar.selIndex-1,1,9)
		elseif b=="wd" or b=="wr" then
			UI.hotbar.selIndex=math.Limit(UI.hotbar.selIndex+1,1,9)
		end
	end
end

function UI.mousemoved(x,y,dx,dy)
	local ox = math.floor((x+state.viewPort.x)/tileW) -- world x
	local oy = math.floor((y+state.viewPort.y)/tileH) -- world y
end

function UI.keypressed(key)
	if tonumber(key) and key~='0' then
		UI.hotbar.selIndex = tonumber(key)
	end
end

function UI.reDraw(w,h)
	-- Hotbar
	local canv = UI.hotBarCanv
	local hw,hh = canv:getWidth(),canv:getHeight()
	local minOpac = .20
	local maxOpac = .68
	love.graphics.setCanvas(canv)
	-- construct glowy hotbar back pane
		love.graphics.setColor(0,255,255,255/2) -- top
		love.graphics.rectangle("fill",1/4*hw,0,hw*3/4,hw*ui.hotBarTop)
		love.graphics.setColor(0,255,255,minOpac*255) -- pane rectangle
		love.graphics.rectangle("fill",1/4*hw,0,hw*3/4,hh)

		love.graphics.setColor(255,255,255,255) -- reset

		love.graphics.setShader(UI.gradientShader) -- gradient construction
		UI.gradientShader:send("a",{0,1,1,maxOpac})
		UI.gradientShader:send("b",{0,1,1,minOpac})
		UI.shadedRect(1/4*hw,0,1/4*hw,hh) -- left
		UI.gradientShader:send("b",{0,1,1,maxOpac})
		UI.gradientShader:send("a",{0,1,1,minOpac})
		UI.shadedRect(hw-3/40*hw,0,3/40*hw,hh) -- right
		love.graphics.setShader()
		love.graphics.setColor(0,255,255,minOpac*255) -- middle
		love.graphics.rectangle("fill",2/4*hw,0,hw-hw*(13/40),hh)

		-- texturing overlay
		--for y=hw*ui.hotBarTop,hh,UI.img.conduitsLeft:getHeight() do
		--	love.graphics.draw(UI.img.conduitsLeft,hw*1/4,y)		end
		--for y=hw*ui.hotBarTop,hh,UI.img.conduitsRight:getHeight() do
		--	love.graphics.draw(UI.img.conduitsRight,math.max(hw-UI.img.conduitsRight:getWidth(),hw*1/4),y)
		--end
		love.graphics.setColor(255,255,255,255/4)
		for x = 1/4*hw,hw,UI.img.noise:getWidth() do 
			for y=hw*ui.hotBarTop,hh,UI.img.noise:getHeight() do
				love.graphics.draw(UI.img.noise,x,y)
			end
		end
		love.graphics.setColor(0,255,255,255)
		UI.lineRect(1/4*hw,0,3/4*hw,hh,3)
	-- ==========================================
	love.graphics.setColor(255,255,255,255)
	-- construct edge
		local tabSpace = Rec(0,0,1/4*hw,hh)
		local tabHeight = hh*ui.hotBarTabHeight
		local tabY = hh/2-tabHeight/2

		love.graphics.setScissor(unpack(tabSpace))
		for piece in tabSpace:iter(Rec(0,0,UI.img.metal:getWidth(),UI.img.metal:getHeight())) do
			love.graphics.draw(UI.img.metal,piece.x,piece.y)
		end

		local coords = {
			1/4*hw,0,
			1/8*hw,1/8*hw,
			1/8*hw,tabY,
			0,tabY+1/8*hw,
			0,tabY+tabHeight-1/8*hw,
			1/8*hw,tabY+tabHeight,
			1/8*hw,hh-1/8*hw,
			1/4*hw,hh
		}
		love.graphics.setColor(20,20,20,255)
		love.graphics.setLineWidth(4)
		love.graphics.line(unpack(coords))

		love.graphics.setScissor()
		love.graphics.setBlendMode("replace")
		love.graphics.setColor(0,0,0,0)
		local coords1 = {
			0,0,
			1/4*hw,0,
			1/8*hw,1/8*hw,
			1/8*hw,tabY,
			0,tabY+1/8*hw
		}
		local coords2 = {
			1/8*hw,hh-1/8*hw,
			1/4*hw,hh,
			0,hh,
			0,tabY+tabHeight-1/8*hw,
			1/8*hw,tabY+tabHeight,
		}
		love.graphics.polygon("fill",unpack(coords1))
		love.graphics.polygon("fill",unpack(coords2))
	-- ==========================================
	love.graphics.reset()
end

-- ========================================== Util ========================================== --

function UI.shadedRect(x,y,w,h)
	local recImg = love.graphics.newImage(love.image.newImageData(w,h))
	love.graphics.draw(recImg,x,y)
end
function UI.lineRect(x,y,w,h,lw)
	love.graphics.rectangle("fill",x,y,w,lw) -- top
	love.graphics.rectangle("fill",x,y+h-lw,w,lw) -- bottom
	love.graphics.rectangle("fill",x,y,lw,h) -- left
	love.graphics.rectangle("fill",x+w-lw,y,lw,h) -- right
end

function UI.placeBlock(i,x,y)
	if love.keyboard.isDown("lctrl","rctrl") then
		game.placeBlock(world,nil,x,y)
	elseif UI.hotbar[i] and not game.getTile(world,x,y) then
		game.placeBlock(world,UI.hotbar[i],x,y)
	elseif not UI.hotbar[i] then
		game.placeBlock(world,nil,x,y)
	end
end

--[[-- experimental conduit gen code. It doesn't look good, in case you're wondering.

	love.graphics.setColor(255,255,255,255/2)
		love.graphics.setLineStyle("rough")
		love.graphics.setLineWidth(1)
		for y=hw*ui.hotBarTop,hh,3 do
			if math.random(0,20)>5 then	
				local last = Vec(1/4*hw,y)
				local line = {last.x,last.y}
				local artifacts = {}
				for x=1/4*hw+5,1/2*hw+math.random(-2,0)*5,5 do
					local diverg = math.random(-5,5)
					local artifact = math.random(0,20)
					table.insert(line,x)
					if diverg==-5 then
						table.insert(line,last.y-5)
					elseif diverg==5 then
						table.insert(line,last.y+5)
					else
						table.insert(line,last.y)
					end
					-- artifacts
					if artifact==0 then
						table.insert(artifacts,{x,y,x+5,y-5})
						table.insert(artifacts,{x+5,y,x+10,y-5})
						table.insert(artifacts,{x+10,y,x+15,y-5})
					end
				end
				love.graphics.line(unpack(line))
				for i,v in ipairs(artifacts) do
					love.graphics.line(unpack(v))
				end
			end
			if math.random(0,20)>5 then	
				local last = Vec(1/4*hw,y)
				local line = {last.x,last.y}
				local artifacts = {}
				for x=hw,1/2*hw+math.random(0,2)*5,-5 do
					local diverg = math.random(-5,5)
					local artifact = math.random(0,20)
					table.insert(line,x)
					if diverg==-5 then
						table.insert(line,last.y-5)
					elseif diverg==5 then
						table.insert(line,last.y+5)
					else
						table.insert(line,last.y)
					end
					-- artifacts
					if artifact==0 then
						table.insert(artifacts,{x,y,x-5,y-5})
						table.insert(artifacts,{x-5,y,x-10,y-5})
						table.insert(artifacts,{x-10,y,x-15,y-5})
					end
				end
				love.graphics.line(unpack(line))
				for i,v in ipairs(artifacts) do
					love.graphics.line(unpack(v))
				end
			end
		end
]]

return UI