local UI = {
	colors={
		scroll=0,
		current=1,
		shade=0,
		[0]={0,0,0,0},
		[1]={0,0,0,255},
		[2]={255,255,255,255}
	},
	frames={
		scroll=0,
		zoom=1,
		offset=Vec(0,0),
		current=1
	},
	clickMode = 0, -- used for eating the click
	colorPickerActive = true,
	--name = "",
}
local game = game
local controls = game.control
local framedRect = require("libs/frameRect")
local trx = require("libs/Trx")
local uuid = require("libs/uuid")

function UI.load()
	-- a couple of constants to make calculations shorter
	local scale = ui.spriteScale
	local dims = Rect(ui.editorPaddingLeft*scale,ui.editorPaddingTop*scale,0,0)
	dims.w = love.graphics.getWidth() - ui.editorPaddingRight*scale - ui.hotBarWidth*love.graphics.getWidth() - dims.x
	dims.h = love.graphics.getHeight() - ui.editorPaddingBottom*scale - dims.y

	-- basic clock, then loading images
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
		palette = love.graphics.newImage("stockData/UI/UI2_palette_selection.png"),
	}
	UI.name = ""
	UI.boxes = {}
	UI.resize(love.graphics.getWidth(),love.graphics.getHeight())
	-- UI.frames[1] = {palette={},imgData={},img=love.graphics.newCanvas(64,64)}
	-- for x=0,64 do
	-- 	UI.frames[1].imgData[x]={}
	-- 	for y=0,64 do
	-- 		UI.frames[1].imgData[x][y]=0
	-- 	end
	-- end
	UI.frames[1] = {name="tile",img=love.graphics.newCanvas(16,16)}
	UI.frames[1].img:clear(255,255,255,255)

	UI.frames.offset.x = dims.w/2
	UI.frames.offset.y = dims.h/2

	controls.new("pickerMod","lctrl","rctrl")
	controls.new("fldfilMod","lalt","ralt")
end

function UI.reload()
	UI.resize(love.graphics.getWidth(),love.graphics.getHeight())
	UI.name = ""
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

	-- frame
	love.graphics.setScissor(dims.x,dims.y,dims.w,dims.h)
	love.graphics.draw(
		UI.frames[UI.frames.current].img,
		dims.x+UI.frames.offset.x,
		dims.y+UI.frames.offset.y,
		0,UI.frames.zoom,UI.frames.zoom,
		UI.frames[UI.frames.current].img:getWidth()/2,
		UI.frames[UI.frames.current].img:getHeight()/2)
	love.graphics.setScissor()

	love.graphics.draw(UI.UICanv,0,0)

	-- color boxes - KEEP OUT OF RESIZE!
	local area = Rect(
		dims.r-scale,
		dims.y+UI.img.cbx:getHeight()*2*scale,
		UI.img.cbx:getWidth()*scale,
		dims.h-UI.img.cbx:getHeight()*5*scale
	)
	local box = Rect(
		dims.r-scale,
		dims.y+UI.img.cbx:getHeight()*scale - UI.colors.scroll*UI.img.cbx:getHeight()*scale,
		UI.img.cbx:getWidth()*scale,
		UI.img.cbx:getHeight()*scale+scale
	)
	local i,index = -1,box:regress(area,Vec(love.mouse.getX(),love.mouse.getY()))
	love.graphics.setScissor(area.x,area.y,area.w,area.h)
	for box in area:iter(box) do
		i = i + 1
		love.graphics.draw(UI.img.cbx,box.x,box.y,0,scale,scale)
		if UI.colors[i] then
			love.graphics.setColor(math.Limit(UI.colors[i][1]-ui.editorShadeDiff,0,255),math.Limit(UI.colors[i][2]-ui.editorShadeDiff,0,255),math.Limit(UI.colors[i][3]-ui.editorShadeDiff,0,255),UI.colors[i][4])
			love.graphics.rectangle("fill",box.x+5*scale,box.y+scale,box.h-5*scale,box.h-5*scale)
			love.graphics.setColor(unpack(UI.colors[i]))
			love.graphics.rectangle("fill",box.x+11*scale,box.y+scale,box.h-5*scale,box.h-5*scale)
			love.graphics.setColor(math.Limit(UI.colors[i][1]+ui.editorShadeDiff,0,255),math.Limit(UI.colors[i][2]+ui.editorShadeDiff,0,255),math.Limit(UI.colors[i][3]+ui.editorShadeDiff,0,255),UI.colors[i][4])
			love.graphics.rectangle("fill",box.x+17*scale,box.y+scale,box.h-5*scale,box.h-5*scale)
			love.graphics.setColor(255,255,255,255)
		end
		if i==index-2 and Vec(love.mouse.getX(),love.mouse.getY()):isWithinRec(area) then
			love.graphics.setColor(255,0,0)
			love.graphics.rectangle("line",box.x,box.y,UI.img.cbx:getWidth()*scale,UI.img.cbx:getHeight()*scale)
			love.graphics.print(i,box.x,box.y+(box.h/2-love.graphics.getFont():getHeight()/2))
			love.graphics.setColor(255,255,255,255)
			love.graphics.rectangle("line",box.x+5*scale,box.y+scale,box.h-5*scale,box.h-5*scale)
			love.graphics.rectangle("line",box.x+11*scale,box.y+scale,box.h-5*scale,box.h-5*scale)
			love.graphics.rectangle("line",box.x+17*scale,box.y+scale,box.h-5*scale,box.h-5*scale)
		end
	end
	love.graphics.setScissor()
	area:del()
	box:del()

	-- frame boxes - KEEP OUT OF RESIZE!
	area = Rect(dims.x,dims.b-(UI.img.fM:getHeight()-1)*scale,dims.w*ui.editorFramesNameRatio-UI.img.etr:getWidth()*scale,UI.img.fM:getHeight()*scale)
	box = Rect(area.x,area.y,area.w*ui.editorFrameSizeRatio,area.h)
	love.graphics.setScissor(area.x,area.y,area.w,area.h)
	for _,box in area:iter(box) do
		love.graphics.rectangle("line",box.x,box.y,box.w,box.h)
	end
	love.graphics.setScissor()

	love.graphics.setColor(10,10,10,255)
	UI.nameBoxTrx:draw()
	--love.graphics.rectangle("fill",UI.nameBoxTrx.bounds.x,UI.nameBoxTrx.bounds.y,UI.nameBoxTrx.bounds.w,UI.nameBoxTrx.bounds.h)

	-- ==========================================
	if UI.colorPickerActive then
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(UI.img.palette,dims.x,dims.y,0,dims.w/UI.img.palette:getWidth(),(dims.h-UI.img.nM:getHeight()*scale)/UI.img.palette:getHeight())
	end

	area:del()
	box:del()
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

	-- tool bar bg
	local progR,progL = 0,0
	love.graphics.draw(UI.img.brL,dims.x,dims.y,0,scale,scale); progR = progR + UI.img.brL:getWidth()*scale
	love.graphics.draw(UI.img.brR,dims.r,dims.y,0,scale,scale,UI.img.brR:getWidth(),0); progL = progL - UI.img.brR:getWidth()*scale
	love.graphics.draw(UI.img.brMR,dims.r+progL,dims.y,0,scale,scale,UI.img.brMR:getWidth(),0); progL = progL - UI.img.brMR:getWidth()*scale
	love.graphics.draw(UI.img.brt,dims.r+progL,dims.y,0,scale,scale,UI.img.brt:getWidth(),0); progL = progL - UI.img.brt:getWidth()*scale
	love.graphics.draw(UI.img.brM,dims.x+progR,dims.y,0,(dims.w-progR+progL)/UI.img.brMR:getWidth(),scale)

	-- tools bg
	love.graphics.draw(UI.img.tlBG,dims.r,dims.y,0,scale,scale,UI.img.tlBG:getWidth(),0)

	-- close button
	love.graphics.draw(UI.img.xbut,dims.x,dims.y,0,scale,scale,UI.img.xbut:getWidth()-6,UI.img.xbut:getHeight()-6)

	-- name box
	progR = dims.x+(ui.editorFramesNameRatio*dims.w-UI.img.etr:getWidth()*scale)
	progL = dims.r-(UI.img.etr:getWidth()-2)*scale
	if UI.nameBoxTrx then UI.name = UI.nameBoxTrx.txt[1] end
	UI.nameBoxTrx = trx(UI.name,
		progR+scale*4,
		dims.b-UI.img.nM:getHeight()-scale*2,
		progL-progR-UI.img.nL:getWidth()*scale-UI.img.nR:getWidth()*scale,
		UI.img.nM:getHeight(),
		true)
	UI.nameBoxTrx:load()
	love.graphics.draw(UI.img.nL,progR,dims.b,0,scale,scale,0,UI.img.nL:getHeight()-1); progR = progR + UI.img.nL:getWidth()*scale
	love.graphics.draw(UI.img.nR,progL,dims.b,0,scale,scale,UI.img.nR:getWidth(),UI.img.nR:getHeight()-1); progL = progL - UI.img.nR:getWidth()*scale
	love.graphics.draw(UI.img.nM,progL,dims.b,0,(progR-progL)/UI.img.nM:getWidth(),scale,0,UI.img.nM:getHeight()-1)


	-- frames
	progR = dims.x
	progL = dims.x+(ui.editorFramesNameRatio*dims.w-UI.img.etr:getWidth()*scale)
	love.graphics.draw(UI.img.fL,dims.x,dims.b,0,scale,scale,0,UI.img.fL:getHeight()-1); progR = progR + UI.img.fL:getWidth()*scale
	love.graphics.draw(UI.img.fR,progL,dims.b,0,scale,scale,UI.img.fR:getWidth(),UI.img.fR:getHeight()-1); progL = progL - UI.img.fR:getWidth()*scale
	love.graphics.draw(UI.img.fM,progR,dims.b,0,(progL-progR)/UI.img.fM:getWidth(),scale,0,UI.img.fM:getHeight()-1)
	
	-- enter button
	love.graphics.draw(UI.img.etr,dims.r,dims.b,0,scale,scale,UI.img.etr:getWidth()-1,UI.img.etr:getHeight()-1)

	dims:del()
	love.graphics.setCanvas()
end

function UI.mousemoved(x,y,dx,dy)
	local scale = ui.spriteScale

	local dims = Rect(ui.editorPaddingLeft*scale,ui.editorPaddingTop*scale,0,0)

	dims.w = love.graphics.getWidth() - dims.x - (ui.editorPaddingRight*scale + ui.hotBarWidth*love.graphics.getWidth())
	dims.h = love.graphics.getHeight() - dims.y - ui.editorPaddingBottom*scale

	local pos = Vec(x,y)
	local dpos = Vec(dx,dy)
	local frame = UI.frames[UI.frames.current]
	local frameDims = Vec(frame.img:getWidth(),frame.img:getHeight())

	if UI.clickMode==0 then
		if love.mouse.isDown("m") then
			if pos:isWithinRec(dims) then
				UI.frames.offset:inc(dpos)
			end
			--UI.frames.offset = UI.frames.offset:limit(Vec.zero,dims.dims-frameDims*UI.frames.zoom)
		end

		if love.mouse.isDown("l") then
			UI.drawLine(UI.fromSX(x),UI.fromSY(y),dx/UI.frames.zoom,dy/UI.frames.zoom,unpack(UI.getCColor()))
		elseif love.mouse.isDown("r") then
			UI.drawLine(UI.fromSX(x),UI.fromSY(y),dx/UI.frames.zoom,dy/UI.frames.zoom,unpack(UI.getCColor(0,0)))
		end
	end

	UI.nameBoxTrx:mousemoved(x,y,dx,dy)

	dpos:del()
	pos:del()
	dims:del()
end

function UI.mousepressed(x,y,b)
	local scale = ui.spriteScale
	local dims = Rect(ui.editorPaddingLeft*scale,ui.editorPaddingTop*scale,0,0)
	dims.w = love.graphics.getWidth() - ui.editorPaddingRight*scale - ui.hotBarWidth*love.graphics.getWidth() - dims.x
	dims.h = love.graphics.getHeight() - ui.editorPaddingBottom*scale - dims.y
	-- used to fix some of the ordering bullshit with the color picker
	local togglingColorSelector = false

	local colorDims = Rect(dims.r-scale,dims.y+UI.img.cbx:getHeight()*2*scale,UI.img.cbx:getWidth()*scale,dims.h-UI.img.cbx:getHeight()*5*scale)

	local pos = Vec(x,y)
	if UI.clickMode == 0 then
		-- zooming and panning
		if b=="wu" then
			if x>dims.r and x<dims.r+UI.img.cbx:getWidth()*scale then
				UI.colors.scroll = math.Limit(UI.colors.scroll-.4,0,math.huge)
			elseif pos:isWithinRec(dims) then
				UI.frames.zoom = UI.frames.zoom + .1
			end
		elseif b=="wd" then
			if x>dims.r and x<dims.r+UI.img.cbx:getWidth()*scale then
				UI.colors.scroll = math.Limit(UI.colors.scroll+.4,0,math.huge)
			elseif pos:isWithinRec(dims) then
				UI.frames.zoom = UI.frames.zoom - .1
			end
		end

		-- simply drawing pixels
		if pos:isWithinRec(dims) then
			if controls.isDown("pickerMod") then
				local c = UI.colors[UI.colors.current]
				c[1],c[2],c[3],c[4] = UI.frames[UI.frames.current].img:getPixel(UI.fromSX(x),UI.fromSY(y))
			else
				if b=="l" then
					UI.drawPixel(UI.fromSX(x),UI.fromSY(y),unpack(UI.getCColor()))
				elseif b=="r" then
					UI.drawPixel(UI.fromSX(x),UI.fromSY(y),unpack(UI.getCColor(0,0)))
				end
			end
		end
		-- color selection
		if b=="l" and pos:isWithinRec(colorDims) then
			-- declaring general rects; used for the basic detection
			local box = Rect(dims.r-scale,dims.y+UI.img.cbx:getHeight()*(2-(UI.colors.scroll%1)*UI.img.cbx:getHeight())*scale,UI.img.cbx:getWidth()*scale,UI.img.cbx:getHeight()*scale+scale)
			local index = box:regress(colorDims,Vec(love.mouse.getX(),love.mouse.getY()))-1

			-- declaring subrects; used for shade specification, declared using the dimensions of the previous.
			local shade=Rect(box.x+5*scale,box.y+scale+(index-1)*box.h,box.h-5*scale,box.h-5*scale)
			local main=Rect(box.x+11*scale,box.y+scale+(index-1)*box.h,box.h-5*scale,box.h-5*scale)
			local light=Rect(box.x+17*scale,box.y+scale+(index-1)*box.h,box.h-5*scale,box.h-5*scale)

			-- darker shade selection
			if pos:isWithinRec(shade) then
				if index==UI.colors.current then
					UI.clickMode = 1
					UI.colorPickerActive = true
					togglingColorSelector = true
					--[[game.system.enableUI("colorPicker")]]
				end
				UI.colors.current = index
				UI.colors.shade = -1
			end
			-- mid shade selection
			if pos:isWithinRec(main) then
				if index==UI.colors.current then
					UI.clickMode = 1
					UI.colorPickerActive = true
					togglingColorSelector = true
					--[[game.system.enableUI("colorPicker")]]
				end
				UI.colors.current = index
				UI.colors.shade = 0
			end
			-- light shade selection
			if pos:isWithinRec(light) then
				if index==UI.colors.current then
					UI.clickMode = 1
					UI.colorPickerActive = true
					togglingColorSelector = true
					--[[game.system.enableUI("colorPicker")]]
				end
				UI.colors.current = index
				UI.colors.shade = 1
			end
			UI.getCColor()
			-- print(UI.colors.current)
			-- print(unpack(UI.getCColor()))
			box:del();shade:del();main:del();light:del()
		elseif b=="l" and pos:isWithinRec(Rec(dims.x-(UI.img.xbut:getWidth()-6)*scale,dims.y-(UI.img.xbut:getHeight()-6)*scale,9*scale,9*scale):del()) then
			game.system.disableUI("pixelEditor")
		end
	end

	if pos:isWithinRec(UI.nameBoxTrx.bounds) then
		UI.clickMode = 2
		UI.colorPickerActive = false
		UI.nameBoxTrx:mousepressed(x,y,b)
	elseif UI.colorPickerActive then
		if pos:isWithinRec(dims) and pos.y<dims.b-UI.img.nM:getHeight()*scale and b=='l' then
			UI.clickMode = 1
			local palettePos = Vec(
				math.floor((x-dims.x)*UI.img.palette:getWidth()/dims.w),
				math.floor((y-dims.y)*UI.img.palette:getHeight()/(dims.h-UI.img.nM:getHeight()*scale))
			)
			local c = UI.colors[UI.colors.current]
			c[1],c[2],c[3],c[4] = UI.img.palette:getData():getPixel(palettePos.x,palettePos.y)
			palettePos:del()
		end
		if not togglingColorSelector then
			UI.clickMode = 0
			UI.colorPickerActive = false
		end
	else
		UI.clickMode = 0
		UI.colorPickerActive = false
	end

	-- confirmation
	local button = Rect(dims.r-UI.img.etr:getWidth()*scale,dims.b-UI.img.etr:getHeight()*scale,UI.img.etr:getWidth()*scale,UI.img.etr:getWidth()*scale)
	if pos:isWithinRec(button) then
		UI.save()
		game.system.disableUI("pixelEditor")
	end
	button:del()

	dims:del()
	pos:del()
	colorDims:del()
end

function UI.mousereleased(x,y,b)
	if UI.clickMode == 2 then
		UI.nameBoxTrx:mousereleased(x,y,b)
	end
end

function UI.textinput(txt)
	if UI.clickMode == 2 then
		UI.nameBoxTrx:textinput(txt)
	end
end

function UI.keypressed(k)
	if UI.clickMode == 2 then
		UI.nameBoxTrx:keypressed(k)
	end
end

function UI.keyreleased(k)
	--UI.nameBoxTrx:keyreleased(k)
end

-- ==========================================

	function UI.getCColor(i,s)
		i = i or UI.colors.current
		s = s or UI.colors.shade
		if not UI.colors[i] then
			UI.colors[i]={255,255,255,255}
		end
		local c = UI.colors[i]
		if s~=0 then
			local cn = {math.Limit(c[1]+s*ui.editorShadeDiff,0,255),math.Limit(c[2]+s*ui.editorShadeDiff,0,255),math.Limit(c[3]+s*ui.editorShadeDiff,0,255),c[4]}
			return cn
		else
			return c
		end
	end

	function UI.fromSX(x) -- from screen x to canvas x
		return math.floor((x-ui.editorPaddingLeft*ui.spriteScale-UI.frames.offset.x+UI.frames[UI.frames.current].img:getWidth()/2*UI.frames.zoom)/UI.frames.zoom)
	end
	function UI.fromSY(y) -- from screen y to canvas y
		return math.floor((y-ui.editorPaddingTop*ui.spriteScale-UI.frames.offset.y+UI.frames[UI.frames.current].img:getHeight()/2*UI.frames.zoom)/UI.frames.zoom)
	end
	function UI.fromS(x,y) -- from screen coords to canvas coords
		return UI.fromSX(x),UI.fromSY(y)
	end

	function UI.drawPixel(x,y,r,g,b,a)
		local pos = Vec(x+1,y+1)
		local bm1,bm2 = love.graphics.getBlendMode()
		love.graphics.setBlendMode("replace","alpha")
		love.graphics.setPointSize(0.1)
		love.graphics.setPointStyle("rough")

		love.graphics.setCanvas(UI.frames[UI.frames.current].img)
		love.graphics.setColor(r,g,b,a)

		love.graphics.point(pos.x-1,pos.y)

		love.graphics.setCanvas()
		love.graphics.setBlendMode(bm1,bm2)
		love.graphics.setColor(255,255,255,255)
		pos:del()
	end

	function UI.drawLine(x,y,dx,dy,r,g,b,a)
		local bm1,bm2 = love.graphics.getBlendMode()
		local scissx,scissy,scissw,scissh = love.graphics.getScissor()
		love.graphics.setBlendMode("replace","alpha")
		love.graphics.setPointSize(1)
		love.graphics.setPointStyle("rough")
		love.graphics.setCanvas(UI.frames[UI.frames.current].img)
		love.graphics.setColor(r,g,b,a)
		-- also horrible inconsistent results, but not *quite* as bad for the most part. :<
		for i,ix,iy in bresenham(x,y+1,x-dx,y+1-dy) do
			love.graphics.point(ix,iy)
		end
		-- horrible inconsistent results.
		--love.graphics.setLineStyle("rough")
		--love.graphics.setLineWidth(1)
		--love.graphics.line(math.floor(x+1)+0.5,math.floor(y+1)+0.5,math.floor(x+1)+0.5+math.floor(dx),math.floor(y+1)+0.5+math.floor(dy))

		love.graphics.setScissor(scissx,scissy,scissw,scissh)
		love.graphics.setBlendMode(bm1,bm2)
		love.graphics.setColor(255,255,255,255)
		love.graphics.setCanvas()
		-- pos:del()
		-- dist:del()
	end

	local l,r,u,d = string.byte("l"),string.byte("r"),string.byte("u"),string.byte("d")
	local function getCellData(cell)
		return cell:byte(1)==l,cell:byte(2)==r,cell:byte(3)==u,cell:byte(4)==d,cell:match("(%d+).(%d+)")
	end
	function UI.floodFill(x,y,r,g,b,a,br,bg,bb,ba)
		local bm1,bm2 = love.graphics.getBlendMode()
		local scissx,scissy,scissw,scissh = love.graphics.getScissor()
		local canv = UI.frames[UI.frames.current].img
		love.graphics.setBlendMode("replace","alpha")
		love.graphics.setPointSize(1)
		love.graphics.setPointStyle("rough")
		love.graphics.setCanvas(canv)

		-- ex. cell: "lrud17,5"
		local l,r,u,d,xp,yp
		local lastCount = 0
		local deadCells = {}
		local liveCells = {}
		local nextCells = {}
		repeat
			for i,v in ipairs(liveCells) do
				l,r,u,d,xp,yp = getCellData(v)
				local cr,cg,cb,ca = canv:getPixel(xp,yp)
				table.insert(deadCells,xp)
				table.insert(deadCells,yp)
			end
			lastCount = #liveCells
			for i=1,#liveCells do
				table.remove(liveCells,#liveCells)
			end
		until #liveCells<=0


		love.graphics.setScissor(scissx,scissy,scissw,scissh)
		love.graphics.setBlendMode(bm1,bm2)
		love.graphics.setColor(255,255,255,255)
		love.graphics.setCanvas()
	end
	--print(getCellData("lrud17,5"))

	function UI.save()
		print("saving!")
		local path = "Player/Inventory/unsorted/"..uuid()
		love.filesystem.createDirectory(path)
		path = path.."/"

		local name = #UI.nameBoxTrx.txt[1]>0 and UI.nameBoxTrx.txt[1] or "Block"
		local settings = {type="Tile",solid=true,name=name,layer=4}
		love.filesystem.write(path.."settings.json",json.encode(settings))

		love.filesystem.createDirectory(path.."frames")
		love.filesystem.createDirectory(path.."assets")
		path = path.."frames/"

		for i,v in ipairs(UI.frames) do
			v.img:getImageData():encode(path..v.name..".png")
		end
	end

return UI