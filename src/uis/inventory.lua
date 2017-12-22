local UI = {zoom = 2,bmScroll=0,mScroll=0,path="Player/Inventory/unsorted",items = {},itemTypes = {},folders = {},cursorItem = nil}
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
	controls.new("iscrlUp",'wu')
	controls.new("iscrlDn",'wd')
	controls.new("zoom",'lctrl','rctrl')
	controls.new("select",'l')
	UI.resize(love.graphics.getWidth(),love.graphics.getHeight())
	UI.updateFileSet(UI.path)
	UI.bmScroll = 0
	UI.mScroll = 0
end

function UI.reload()
	UI.resize(love.graphics.getWidth(),love.graphics.getHeight())
	UI.updateFileSet(UI.path)
	UI.bmScroll = 0
	UI.mScroll = 0
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

	-- main thing
	local bounds = Rect(dims.x+dims.w*ui.invSideRatio,dims.y,dims.w-dims.w*ui.invSideRatio,dims.h)
	local iSpace = Rect(bounds.x,bounds.y,tileW+ui.invItemPadding*2,tileH+ui.invItemPadding*2+love.graphics.getFont():getHeight()*2)
	iSpace.w = iSpace.w*UI.zoom
	iSpace.h = iSpace.h*UI.zoom
	iSpace.y = iSpace.y-UI.mScroll%1*iSpace.h
	love.graphics.setScissor(bounds.x,bounds.y,bounds.w+iSpace.w,bounds.h)
	local vi = iSpace:regress(bounds,Vec(love.mouse.getX(),love.mouse.getY()):del()) + (math.floor(UI.mScroll)-1)*math.floor(bounds.w/iSpace.w)
	bounds.w = bounds.w -(tileW+ui.invItemPadding*2)*UI.zoom
	local i = math.floor(UI.mScroll)*math.ceil(bounds.w/iSpace.w)
	for space in bounds:iter(iSpace) do
		i = i + 1
		love.graphics.rectangle("line",space.x,space.y,space.w,space.h)
		love.graphics.print(i,iSpace.x,iSpace.y)
		if i==vi and Vec(love.mouse.getX(),love.mouse.getY()):isWithinRec(bounds) then
			love.graphics.setColor(255,255,255,255/2)
			love.graphics.rectangle("fill",iSpace.x,iSpace.y,iSpace.w,iSpace.h)
			love.graphics.setColor(255,255,255,255)
		end
		if UI.items[i] then
			UI.displayItem(UI.items[i],UI.items[i].path,iSpace,true)
		end
	end
	love.graphics.setScissor()

	bounds:del()
	love.graphics.draw(UI.UICanv,0,0)
	if UI.cursorItem then
		iSpace.mx = love.mouse.getX()
		iSpace.my = love.mouse.getY()
		UI.displayItem(UI.cursorItem,UI.cursorItem.path,iSpace)
	end
	love.graphics.setScissor()
	iSpace:del()
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
	if pos:isWithinRec(Rec(dims.x+dims.w*ui.invSideRatio,dims.y,dims.w-dims.w*ui.invSideRatio,dims.h):del()) then
		if controls.isIn("iscrlDn",b) then
			if controls.isDown("zoom") then
				UI.zoom = UI.zoom > .1 and UI.zoom - .1 or .1
			else
				UI.mScroll = UI.mScroll + .4
			end
		end
		if controls.isIn("iscrlUp",b) then
			if controls.isDown("zoom") then
				UI.zoom = UI.zoom + .1
			else
				UI.mScroll = UI.mScroll - .4
			end
		end
		if controls.isIn("select",b) then
			local bounds = Rect(dims.x+dims.w*ui.invSideRatio,dims.y,dims.w-dims.w*ui.invSideRatio,dims.h)
			local iSpace = Rect(bounds.x,bounds.y,tileW+ui.invItemPadding*2,tileH+ui.invItemPadding*2+love.graphics.getFont():getHeight()*2)
			iSpace.w = iSpace.w*UI.zoom
			iSpace.h = iSpace.h*UI.zoom
			iSpace.y = iSpace.y-UI.mScroll%1*iSpace.h
			local i = iSpace:regress(bounds,Vec(x,y):del()) + (math.floor(UI.mScroll)-1)*math.floor(bounds.w/iSpace.w)
			if UI.items[i] then
				--print("GOTCHA ONE")
				UI.cursorItem = UI.items[i]
			else
				--print(i)
			end

			iSpace:del()
			bounds:del()
		end
	end

	dims:del()
	pos:del()
end

function UI.mousereleased(x,y,b)
	if UI.cursorItem and game.system.getUI("hotbar") then
		local hb = game.system.getUI("hotbar")
		local area = hb.bounds
		local item = Rec(hb.bounds.x,hb.bounds.y+ui.hotBarPadding*ui.hotBarWidth*love.graphics.getWidth() - hb.hotbar.scroll*(hb.bounds.w+ui.hotBarPadding*ui.hotBarWidth*love.graphics.getWidth()),hb.bounds.w,hb.bounds.w-ui.hotBarPadding*ui.hotBarWidth*love.graphics.getWidth())
		local index = item:regress(area,Vec(x,y):del())-1
		hb.hotbar[index] = UI.cursorItem
		item:del()
	end
	UI.cursorItem = nil
end

-- ==========================================

function UI.displayItem(item,path,rect,intersectScissor)
	local sciss = Rect(love.graphics.getScissor())
	local intersection
	if intersectScissor then
		intersection = rect:copy()--rect:intersection(sciss)
		love.graphics.setScissor(intersection.x,intersection.y,intersection.w,intersection.h)
	else
		love.graphics.setScissor(rect.x,rect.y,rect.w,rect.h)
	end

	local text = item.properties.name
	local itype = item.properties.type
	local icon = item.frames.icon or item.frames.tile or item.frames[1]
	local yprog = rect.y+ui.invItemPadding
	local imgh = (rect.h-ui.invItemPadding*2-love.graphics.getFont():getHeight()*2*UI.zoom) -- temporarily stored because we use it in the print too
	local fontScale = 1--(rect.h-ui.invItemPadding*2-imgh)/2/love.graphics.getFont():getHeight()

	love.graphics.draw(icon,rect.x+ui.invItemPadding,yprog,0,(rect.w-ui.invItemPadding*2)/icon:getWidth(),imgh/icon:getHeight());yprog = yprog + imgh
	
	--love.graphics.scale(fontScale,fontScale)
	love.graphics.print(tostring(text),(rect.x+ui.invItemPadding)/fontScale,yprog/fontScale);yprog = yprog + love.graphics.getFont():getHeight()
	love.graphics.setColor(255,255,255,255/2)
	love.graphics.print(tostring(itype),(rect.x+ui.invItemPadding)/fontScale,yprog/fontScale)
	--love.graphics.scale(1/fontScale,1/fontScale)

	love.graphics.setScissor(sciss.x,sciss.y,sciss.w,sciss.h)
	--sciss:del();
	if intersection then 
		intersection:del()
	end
	love.graphics.setColor(255,255,255,255)
end

function UI.updateFileSet(path)
	UI.folder = {}
	UI.itemTypes = {}
	UI.items = {}
	local typequeue = {}
	local itemPath,data
	love.graphics.setDefaultFilter("nearest","nearest")
	for i,v in ipairs(love.filesystem.getDirectoryItems('/'..path)) do
		itemPath = path..'/'..v
		if love.filesystem.isFile(itemPath.."/settings.json") then
			local item = {}
			data = love.filesystem.read(itemPath.."/settings.json")
			data = json.decode(data)
			item.properties = data
			item.frames = {}
			for ii,iv in ipairs(love.filesystem.getDirectoryItems('/'..itemPath.."/frames")) do
				local fileName = string.match(iv,"(%w+)%.")
				fileName = tonumber(fileName) or fileName
				item.frames[fileName] = love.graphics.newImage(itemPath.."/frames/"..iv)
			end

			-- TODO @ALPHA : actual sorting and shit
			UI.items[data.name] = item
			UI.items[data.name].path = itemPath
			table.insert(UI.items,UI.items[data.name])
		elseif love.filesystem.isDirectory(itemPath) then
			UI.folder[itemPath]=true
		end
	end
end

return UI