local UI = {}
local game = require("libs/game")
local controls = game.control
local framedRect = require("libs/frameRect")

function UI.load()
	UI.clock = 0
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
		sep = love.graphics.newImage("stockData/UI/UI3_separator.png")
	}
	UI.resize(love.graphics.getWidth(),love.graphics.getHeight())
end

function UI.update(dt) UI.clock = UI.clock + dt end

function UI.draw()
	-- a couple of constants to make calculations shorter
	local scale = ui.spriteScale
	local dims = Rect(ui.editorPaddingLeft*scale,ui.editorPaddingTop*scale,0,0)
	dims.w = love.graphics.getWidth() - ui.editorPaddingRight*scale - ui.hotBarWidth*love.graphics.getWidth() - dims.x
	dims.h = love.graphics.getHeight() - ui.editorPaddingBottom*scale - dims.y

	-- background
	love.graphics.setColor(UI.img.bgCol:getData():getPixel(0,0))
	love.graphics.rectangle("fill",dims.x,dims.y,dims.w,dims.h)
	love.graphics.setColor(255,255,255,255)

	love.graphics.draw(UI.UICanv,0,0)
end

function UI.mousemoved(x,y,dx,dy)
	local scale = ui.spriteScale

	local dims = Rect(ui.editorPaddingLeft*scale,ui.editorPaddingTop*scale,0,0)

	dims.w = love.graphics.getWidth() - dims.x - (ui.editorPaddingRight*scale + ui.hotBarWidth*love.graphics.getWidth())
	dims.h = love.graphics.getHeight() - dims.y - ui.editorPaddingBottom*scale

	local pos = Vec(x,y)
	local dpos = Vec(dx,dy)

	dpos:del()
	pos:del()
	dims:del()
end

function UI.resize(w,h)
	UI.UICanv = love.graphics.newCanvas(w,h)
	love.graphics.setCanvas(UI.UICanv)

	local scale = ui.spriteScale
	local dims = Rect(ui.editorPaddingLeft*scale,ui.editorPaddingTop*scale,0,0)
	dims.w = love.graphics.getWidth() - ui.editorPaddingRight*scale - ui.hotBarWidth*love.graphics.getWidth() - dims.x
	dims.h = love.graphics.getHeight() - ui.editorPaddingBottom*scale - dims.y

	-- border
	framedRect(dims,UI.img.TL,UI.img.TR,UI.img.BL,UI.img.BR,UI.img.T,UI.img.L,UI.img.B,UI.img.R,true,false,scale,scale)

	-- close button
	love.graphics.draw(UI.img.xbut,dims.x,dims.y,0,scale,scale,UI.img.xbut:getWidth()-6,UI.img.xbut:getHeight()-6)

	-- sidebar side
	love.graphics.draw(UI.img.sep,dims.x+dims.w*ui.invSideRatio-UI.img.sep:getWidth()*scale,dims.y,0,scale,dims.h/UI.img.sep:getHeight())

	dims:del()
	love.graphics.setCanvas()
end

function UI.mousepressed(x,y,b)
	local scale = ui.spriteScale
	local dims = Rect(ui.editorPaddingLeft*scale,ui.editorPaddingTop*scale,0,0)
	dims.w = love.graphics.getWidth() - ui.editorPaddingRight*scale - ui.hotBarWidth*love.graphics.getWidth() - dims.x
	dims.h = love.graphics.getHeight() - ui.editorPaddingBottom*scale - dims.y

	local pos = Vec(x,y)

	if b=="l" and pos:isWithinRec(Rec(dims.x-(UI.img.xbut:getWidth()-6)*scale,dims.y-(UI.img.xbut:getHeight()-6)*scale,9*scale,9*scale):del()) then
		game.system.disableUI("inventory")
	end

	dims:del()
	pos:del()
end

-- ==========================================

return UI