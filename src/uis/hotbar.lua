local UI = {hotbar = {scroll=0,selIndex=1,shown=true}} -- remnant of an older system
--@TODO ALPHA: organize sensibly with new system
require("libs/util")
local framedRect = require("libs/frameRect")

function UI.load()
	love.graphics.setDefaultFilter("nearest","nearest")
	UI.img = {
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
	UI.resize(gw(),gh())
end

function UI.draw()
	local scale = ui.spriteScale

	if UI.hotbar.shown then
		-- background
		love.graphics.setColor(UI.img.bgCol:getData():getPixel(0,0))
		love.graphics.rectangle("fill",UI.bounds.x,UI.bounds.y-scale,UI.bounds.w,UI.bounds.h+scale)
		love.graphics.setColor(255,255,255,255)

		framedRect(UI.bounds,UI.img.TL,UI.img.TR,UI.img.BL,UI.img.BR,UI.img.T,UI.img.L,UI.img.B,UI.img.R,true,false,scale,scale)

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

function UI.resize(w,h)
	UI.bounds = Rect(gw()-gw()*ui.hotBarWidth,(gh()-gh()*ui.hotBarHeight)/2,gw()*ui.hotBarWidth,gh()*ui.hotBarHeight)
end

return UI