local UI = {hotbar = {scroll=0,selIndex=1,shown=true}} -- remnant of an older system
--@TODO ALPHA: organize sensibly with new system
require("libs/util")
local game = game
local framedRect = require("libs/frameRect")

function UI.load()
	controls.new("place",'l')
	controls.new("destMod",'lctrl','rctrl')
	controls.new("scrlUp",'wu','wl')
	controls.new("scrlDn",'wd','wr')
	love.graphics.setDefaultFilter("nearest","nearest")
	UI.img = {
		err = love.graphics.newImage("stockData/tiles/errorBlock.png"),

		TL = love.graphics.newImage("stockData/UI/UI1_border1_TL.png"),
		TR = love.graphics.newImage("stockData/UI/UI1_border1_TR.png"),
		BL = love.graphics.newImage("stockData/UI/UI1_border1_BL.png"),
		BR = love.graphics.newImage("stockData/UI/UI1_border1_BR.png"),
		T = love.graphics.newImage("stockData/UI/UI1_border1_T.png"),
		L = love.graphics.newImage("stockData/UI/UI1_border1_L.png"),
		R = love.graphics.newImage("stockData/UI/UI1_border1_R.png"),
		B = love.graphics.newImage("stockData/UI/UI1_border1_B.png"),

		craft = love.graphics.newImage("stockData/UI/UI1_buttons_craft.png"),
		inventory = love.graphics.newImage("stockData/UI/UI1_buttons_inventory.png"),
		up = love.graphics.newImage("stockData/UI/UI1_buttons_up.png"),
		down = love.graphics.newImage("stockData/UI/UI1_buttons_down.png"),
		show = love.graphics.newImage("stockData/UI/UI1_buttons_show.png"),
		hide = love.graphics.newImage("stockData/UI/UI1_buttons_hide.png"),

		bgCol = love.graphics.newImage("stockData/UI/UI2_backg_color.png"),
	}
	UI.baseFont = love.graphics.newFont(1)
	UI.resize(gw(),gh())
end

local last = Vec(0,0)
local placedLast = false
function UI.update(dt)
	local ox = math.floor((love.mouse.getX()+state.viewPort.x)/tileW) -- world x
	local oy = math.floor((love.mouse.getY()+state.viewPort.y)/tileH) -- world y

	if controls.isDown('place') and not Vec(love.mouse.getX(),love.mouse.getY()):isWithinRec(UI.bounds) and not game.system.isUIEnabled("pixelEditor") and not game.system.isUIEnabled("inventory") then
		if last then
			UI.placeLine(last.x,last.y,ox,oy)
			placedLast=true
		else
			UI.placeBlock(ox,oy)
			placedLast=true
		end
	else
		placedLast = false
	end
	last = Vec(ox,oy)
end

function UI.draw()
	local scale = ui.spriteScale

	if UI.hotbar.shown then
		-- background
		love.graphics.setColor(UI.img.bgCol:getData():getPixel(0,0))
		love.graphics.rectangle("fill",UI.bounds.x,UI.bounds.y-scale,UI.bounds.w,UI.bounds.h+scale)
		love.graphics.setColor(255,255,255,255)

		-- items
		love.graphics.setScissor(UI.bounds.x,UI.bounds.y,UI.bounds.w,UI.bounds.h)
		local padding = ui.hotBarPadding*ui.hotBarWidth*love.graphics.getWidth()
		local y = UI.bounds.y+padding - UI.hotbar.scroll*(UI.bounds.w+padding)
		for i=1,9 do
			local bm1,bm2 = love.graphics.getBlendMode()
			local font = love.graphics.getFont()
			love.graphics.setBlendMode("additive","alpha")
			love.graphics.setColor(UI.img.bgCol:getData():getPixel(0,0))

			love.graphics.rectangle("fill",UI.bounds.x+padding,y,UI.bounds.w-padding*2,UI.bounds.w-padding*2)
			love.graphics.rectangle("line",UI.bounds.x+padding,y,UI.bounds.w-padding*2,UI.bounds.w-padding*2)

			love.graphics.setFont(UI.bigFont)
			love.graphics.printf(i,UI.bounds.x+padding,y-padding*2,UI.bounds.w-padding*2,"center")
			love.graphics.setFont(font)

			love.graphics.setColor(255,255,255,255)
			if i==UI.hotbar.selIndex then
				love.graphics.rectangle("line",UI.bounds.x+padding,y,UI.bounds.w-padding*2,UI.bounds.w-padding*2)
			end
			love.graphics.setBlendMode(bm1,bm2)
			if UI.hotbar[i] then
				local img = UI.hotbar[i].frames.tile or UI.hotbar[i].frames.icon or UI.hotbar[i].frames[1] or UI.img.err
				love.graphics.draw(img,UI.bounds.x+padding*2,y+padding,0,(UI.bounds.w-padding*4)/img:getWidth(),(UI.bounds.w-padding*4)/img:getHeight())
			end
			y = y + UI.bounds.w-padding
		end
		love.graphics.setScissor()
		-- ==========================================

		framedRect(UI.bounds,UI.img.TL,UI.img.TR,UI.img.BL,UI.img.BR,UI.img.T,UI.img.L,UI.img.B,UI.img.R,true,false,scale,scale)

		-- hiding button thing
		love.graphics.draw(UI.img.hide,UI.bounds.x-UI.img.L:getWidth()*scale,UI.bounds.y+UI.bounds.h/2-UI.img.hide:getHeight()*scale/2,0,scale,scale,UI.img.hide:getWidth(),0)

		-- buttons :P
		local progR = UI.bounds.x
		local w = (UI.img.craft:getWidth() + UI.img.up:getWidth() + UI.img.inventory:getWidth())*scale
		progR = progR + (UI.bounds.w/2 - w/2)
		love.graphics.draw(UI.img.craft,progR,UI.bounds.y,0,scale,scale,0,UI.img.craft:getHeight()); progR = progR + UI.img.craft:getWidth()*scale
		love.graphics.draw(UI.img.up,progR,UI.bounds.y,0,scale,scale,0,UI.img.craft:getHeight()); progR = progR + UI.img.up:getWidth()*scale
		love.graphics.draw(UI.img.inventory,progR,UI.bounds.y,0,scale,scale,0,UI.img.inventory:getHeight()); progR = progR + UI.img.inventory:getWidth()*scale
	else

	end
end

function UI.mousepressed(x,y,b)
	local pos = Vec(x,y)
	local scale = ui.spriteScale
	local top_buttons_width = (UI.img.craft:getWidth() + UI.img.up:getWidth() + UI.img.inventory:getWidth())*scale

	if UI.hotbar.shown then
		if pos:isWithinRec(UI.bounds) then
			local itmH=(UI.bounds.w-ui.hotBarPadding*ui.hotBarWidth*love.graphics.getWidth())
			local min,max = 0, 9-(UI.bounds.h/itmH)
			if b=="wu" then
				UI.hotbar.scroll = math.Limit(UI.hotbar.scroll - .25,min,max)
			end
			if b=="wd" then
				UI.hotbar.scroll = math.Limit(UI.hotbar.scroll + .25,min,max)
			end
			if b=="l" then
				local v = Rec(UI.bounds.x,UI.bounds.y+ui.hotBarPadding*ui.hotBarWidth*love.graphics.getWidth() - UI.hotbar.scroll*(UI.bounds.w+ui.hotBarPadding*ui.hotBarWidth*love.graphics.getWidth()),UI.bounds.w,UI.bounds.w-ui.hotBarPadding*ui.hotBarWidth*love.graphics.getWidth())
				local index = v:regress(UI.bounds,pos)-1

				UI.hotbar.selIndex = index

				v:del()
			end
		elseif b=="l" and pos:isWithinRec(Rec(UI.bounds.x+(UI.bounds.w/2-top_buttons_width/2),UI.bounds.y-UI.img.craft:getHeight()*scale,UI.img.craft:getWidth()*scale,UI.img.craft:getHeight()*scale):del()) then
			if game.system.isUIEnabled("pixelEditor") then
				game.system.disableUI("pixelEditor")
			else
				game.system.enableUI("pixelEditor")
			end
		elseif b=="l" and pos:isWithinRec(Rec(UI.bounds.x+(UI.bounds.w/2-top_buttons_width/2)+(UI.img.craft:getWidth()+UI.img.up:getWidth())*scale,UI.bounds.y-UI.img.inventory:getHeight()*scale,UI.img.inventory:getWidth()*scale,UI.img.inventory:getHeight()*scale):del()) then
			if game.system.isUIEnabled("inventory") then
				game.system.disableUI("inventory")
			else
				game.system.enableUI("inventory")
			end
		else
			local ox = math.floor((x+state.viewPort.x)/tileW) -- world x
			local oy = math.floor((y+state.viewPort.y)/tileH) -- world y
			if controls.isIn("place",b) and not game.system.isUIEnabled("pixelEditor") and not game.system.isUIEnabled("inventory") then
				--print(ox,oy)
				UI.placeBlock(ox,oy)
			elseif controls.isIn("scrlUp",b) and not game.system.isUIEnabled("pixelEditor") and not game.system.isUIEnabled("inventory") then
				UI.hotbar.selIndex=math.wrap(UI.hotbar.selIndex-1,1,10)
			elseif controls.isIn("scrlDn",b) and not game.system.isUIEnabled("pixelEditor") and not game.system.isUIEnabled("inventory") then
				UI.hotbar.selIndex=math.wrap(UI.hotbar.selIndex+1,1,10)
			end
		end
	else

	end

	pos:del()
end

function UI.resize(w,h)
	UI.bounds = Rect(gw()-gw()*ui.hotBarWidth,(gh()-gh()*ui.hotBarHeight)/2,gw()*ui.hotBarWidth,gh()*ui.hotBarHeight)
	UI.bigFont = love.graphics.newFont(UI.bounds.w/UI.baseFont:getHeight())
end

-- ==========================================

function UI.placeBlock(x,y)
	local i = UI.hotbar.selIndex
	if x and y then
		if controls.isDown("destMod") then
			game.placeBlock(world,nil,x,y)
		elseif UI.hotbar[i] and not game.getTile(world,x,y) then
			game.placeBlock(world,UI.hotbar[i],x,y)
		elseif not UI.hotbar[i] then
			game.placeBlock(world,nil,x,y)
		end
	end
end
function UI.placeLine(x0,y0,x1,y1)
	for i,x,y in bresenham(x0,y0,x1,y1) do
		UI.placeBlock(x,y)
	end
end

return UI