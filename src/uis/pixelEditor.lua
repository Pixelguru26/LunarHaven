local UI = {}
local game = require("libs/game")
local controls = game.control
local framedRect = require("libs/frameRect")

function UI.load()
	love.graphics.setDefaultFilter("nearest","nearest")
	UI.img = {
		TL = love.graphics.newImage("stockData/UI/UI2_border1_TL.png"),
		TR = love.graphics.newImage("stockData/UI/UI2_border1_TR.png"),
		BL = love.graphics.newImage("stockData/UI/UI2_border1_BL.png"),
		BR = love.graphics.newImage("stockData/UI/UI2_border1_BR.png"),
		T = love.graphics.newImage("stockData/UI/UI2_border1_T.png"),
		L = love.graphics.newImage("stockData/UI/UI2_border1_L.png"),
		R = love.graphics.newImage("stockData/UI/UI2_border1_R.png"),
		B = love.graphics.newImage("stockData/UI/UI2_border1_B.png"),

		brL = love.graphics.newImage("stockData/UI/UI2_tbar1_L.png"),
		brM = love.graphics.newImage("stockData/UI/UI2_tbar1_M.png"),
		brt = love.graphics.newImage("stockData/UI/UI2_tbar1_Trans.png"),
		brMR = love.graphics.newImage("stockData/UI/UI2_tbar1_MR.png"),
		brR = love.graphics.newImage("stockData/UI/UI2_tbar1_R.png"),

		tlBG = love.graphics.newImage("stockData/UI/UI2_tools_BG.png"),
		tlSel = love.graphics.newImage("stockData/UI/UI2_tools_sel.png"),

		nL = love.graphics.newImage("stockData/UI/UI2_name_L.png"),
		nM = love.graphics.newImage("stockData/UI/UI2_name_M.png"),
		nR = love.graphics.newImage("stockData/UI/UI2_name_R.png"),

		fL = love.graphics.newImage("stockData/UI/UI2_frames_L.png"),
		fM = love.graphics.newImage("stockData/UI/UI2_frames_M.png"),
		fR = love.graphics.newImage("stockData/UI/UI2_frames_R.png"),

		xbut = love.graphics.newImage("stockData/UI/UI2_buttons_X.png"),
		etr = love.graphics.newImage("stockData/UI/UI2_buttons_Enter.png"),
		cbx = love.graphics.newImage("stockData/UI/UI2_colorBox.png"),

		bgCol = love.graphics.newImage("stockData/UI/UI2_backg_color.png"),
	}
end

function UI.draw()
	local scale = ui.editorSpriteScale
	local dims = Rect(ui.editorPaddingLeft*scale,ui.editorPaddingTop*scale,0,0)
	dims.w = love.graphics.getWidth() - ui.editorPaddingRight*scale - ui.hotBarWidth*love.graphics.getWidth() - dims.x
	dims.h = love.graphics.getHeight() - ui.editorPaddingBottom*scale - dims.y

	-- background
	love.graphics.setColor(UI.img.bgCol:getData():getPixel(0,0))
	love.graphics.rectangle("fill",dims.x,dims.y,dims.w,dims.h)
	love.graphics.setColor(255,255,255,255)

	-- border
	framedRect(dims,UI.img.TL,UI.img.TR,UI.img.BL,UI.img.BR,UI.img.T,UI.img.L,UI.img.B,UI.img.R,true,false,scale,scale)

	-- tool bar bg
	local progR,progL = 0,0
	love.graphics.draw(UI.img.brL,dims.x,dims.y,0,scale,scale); progR = progR + UI.img.brL:getWidth()*scale
	love.graphics.draw(UI.img.brR,dims.r,dims.y,0,scale,scale,UI.img.brR:getWidth(),0); progL = progL - UI.img.brR:getWidth()*scale
	love.graphics.draw(UI.img.brMR,dims.r+progL,dims.y,0,scale,scale,UI.img.brMR:getWidth(),0); progL = progL - UI.img.brMR:getWidth()*scale
	love.graphics.draw(UI.img.brt,dims.r+progL,dims.y,0,scale,scale,UI.img.brt:getWidth(),0); progL = progL - UI.img.brt:getWidth()*scale
	love.graphics.draw(UI.img.brM,dims.x+progR,dims.y,0,(dims.w-progR+progL)/UI.img.brMR:getWidth(),scale)

	love.graphics.draw(UI.img.tlBG,dims.r,dims.y,0,scale,scale,UI.img.tlBG:getWidth(),0) -- tools bg

	love.graphics.draw(UI.img.xbut,dims.x,dims.y,0,scale,scale,UI.img.xbut:getWidth()-6,UI.img.xbut:getHeight()-6) -- close button

	-- name box
	progR = dims.x+(ui.editorFramesNameRatio*dims.w-UI.img.etr:getWidth()*scale)
	progL = dims.r-(UI.img.etr:getWidth()-2)*scale
	love.graphics.draw(UI.img.nL,progR,dims.b,0,scale,scale,0,UI.img.nL:getHeight()-1); progR = progR + UI.img.nL:getWidth()*scale
	love.graphics.draw(UI.img.nR,progL,dims.b,0,scale,scale,UI.img.nR:getWidth(),UI.img.nR:getHeight()-1); progL = progL - UI.img.nR:getWidth()*scale
	love.graphics.draw(UI.img.nM,progL,dims.b,0,(progR-progL)/UI.img.nM:getWidth(),scale,0,UI.img.nM:getHeight()-1)

	-- frames
	progR = dims.x
	progL = dims.x+(ui.editorFramesNameRatio*dims.w-UI.img.etr:getWidth()*scale)
	love.graphics.draw(UI.img.fL,dims.x,dims.b,0,scale,scale,0,UI.img.fL:getHeight()-1); progR = progR + UI.img.fL:getWidth()*scale
	love.graphics.draw(UI.img.fR,progL,dims.b,0,scale,scale,UI.img.fR:getWidth(),UI.img.fR:getHeight()-1); progL = progL - UI.img.fR:getWidth()*scale
	love.graphics.draw(UI.img.fM,progR,dims.b,0,(progL-progR)/UI.img.fM:getWidth(),scale,0,UI.img.fM:getHeight()-1)

	love.graphics.draw(UI.img.etr,dims.r,dims.b,0,scale,scale,UI.img.etr:getWidth()-1,UI.img.etr:getHeight()-1) -- enter button

	-- color boxes - KEEP OUT OF RESIZE!
	local area = Rect(dims.r-scale,dims.y,UI.img.cbx:getWidth()*scale,dims.h)
	local box = Rect(dims.r-scale,dims.y,UI.img.cbx:getWidth()*scale,UI.img.cbx:getHeight()*scale+scale)

	for _,box in area:iter(box) do
		love.graphics.rectangle("line",box.x,box.y,box.w,box.h)
	end

	area:del()
end

function UI.resize(x,y)

end

-- ==========================================

function UI.blockLine(i,x1,y1,x2,y2)

end

function UI.placeBlock(i,x,y)
	if controls.isDown("destMod") then
		game.placeBlock(world,nil,x,y)
	elseif UI.hotbar[i] and not game.getTile(world,x,y) then
		game.placeBlock(world,UI.hotbar[i],x,y)
	elseif not UI.hotbar[i] then
		game.placeBlock(world,nil,x,y)
	end
end

return UI