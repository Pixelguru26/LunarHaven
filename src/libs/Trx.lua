local Vec = _VECTOR or require("Vec")()
local Rec = _RECTANGLE or require("Rec")()

local lib = {font=love.graphics.newFont("stockData/Bitstream Vera Sans Mono Roman.ttf")}
lib.charSize = Rec(0,0,lib.font:getWidth(" "),lib.font:getHeight())
lib.tabSize = Rec(0,0,lib.font:getWidth("\t"),lib.font:getHeight())
local meta = {}

-- ========================================== caret obj

local caret = {x=0,y=0}

function caret.move(self,dx,dy,txt)
	self.y = self.y+dy<0 and 0 or self.y+dy>#txt-1 and #txt-1 or self.y+dy
	self.x=self.x<0 and 0 or self.x>#txt[self.y+1] and #txt[self.y+1] or self.x
	self.x=self.x+dx
	if self.x<0 then
		if self.y>0 then
			self.y = self.y-1<0 and 0 or self.y-1
			self.x=#txt[self.y+1]
		else
			self.x=0
		end
	elseif self.x>#txt[self.y+1] then
		if self.y<#txt-1 then
			self.y = self.y+1>#txt-1 and #txt-1 or self.y+1
			self.x=0
		else
			self.x=#txt[self.y+1]
		end
	end
end

function caret.set(self,x,y,txt)
	self.y = y<0 and 0 or y>#txt-1 and #txt-1 or y
	self.x = x<0 and 0 or x>#txt[self.y+1] and #txt[self.y+1] or x
end

function caret.insert(self,char,txt,redrawLines)
	txt[self.y+1] = string.sub(txt[self.y+1],0,self.x)..char..string.sub(txt[self.y+1],self.x+1,-1)
	self.x=self.x+#char
	if redrawLines then table.insert(redrawLines,self.y+1) end
end

function caret.del(self,dir,txt,redrawLines)
	if dir<0 then
		if self.x>0 then
			self:move(dir,0,txt)
			txt[self.y+1] = string.sub(txt[self.y+1],0,self.x)..string.sub(txt[self.y+1],self.x-dir+1,-1)
			if redrawLines then table.insert(redrawLines,self.y+1) end
		elseif self.y>0 then
			self:move(-1,0,txt)
			txt[self.y+1]=txt[self.y+1]..table.remove(txt,self.y+2)
			if redrawLines then redrawLines[1]="all" end
		end
	elseif dir>0 then
		if self.x<#txt[self.y+1] then
			txt[self.y+1] = string.sub(txt[self.y+1],0,self.x)..string.sub(txt[self.y+1],self.x+dir+1,-1)
			if redrawLines then table.insert(redrawLines,self.y+1) end
		elseif self.y<#txt then
			txt[self.y+1]=txt[self.y+1]..table.remove(txt,self.y+2)
			if redrawLines then redrawLines[1]="all" end
		end
	end
end

function caret.newLine(self,txt,redrawLines)
	table.insert(txt,self.y+2,string.sub(txt[self.y+1],self.x+1,-1))
	txt[self.y+1] = string.sub(txt[self.y+1],0,self.x)
	self:move(1,0,txt)
	if redrawLines then redrawLines[1]="all" end
end

function caret.new(x,y,txt)
	local c = setmetatable({},{__index=caret})
	c:set(x,y,txt)
	return c
end

-- ========================================== text box obj

local ex = {}

function ex.load(self)
	self.txt=self.txt or {"this is some testy text!","moar testy text"}
	self.cars={caret.new(0,0,self.txt)}
	self.canv=love.graphics.newCanvas(self.bounds.w,self.bounds.h)
	self.redrawLines={}
	self:redraw()
end

function ex.redraw(self,redrawLines)
	local canv,font,blendMode,alphaBM = love.graphics.getCanvas(),love.graphics.getFont(),love.graphics.getBlendMode()
	local br,bg,bb,ba = love.graphics.getColor()

	love.graphics.setCanvas(self.canv)
	love.graphics.setFont(lib.font)

	if not redrawLines or redrawLines[1]=="all" then
		self.canv:clear(0,0,0,0)
		for i,v in ipairs(self.txt) do
			love.graphics.print(v,0,(i-1)*lib.charSize.h)
		end
	else
		for i,v in ipairs(redrawLines) do
			self:redrawLine(v)
		end
		redrawLines={}
	end

	love.graphics.setCanvas(canv);love.graphics.setFont(font);love.graphics.setColor(br,bg,bb,ba);love.graphics.setBlendMode(blendMode,alphaBM)
end

function ex.redrawLine(self,line)
	local canv,font,blendMode,alphaBM = love.graphics.getCanvas(),love.graphics.getFont(),love.graphics.getBlendMode()
	local br,bg,bb,ba = love.graphics.getColor()
	love.graphics.setCanvas(self.canv)
	love.graphics.setFont(lib.font)
	love.graphics.setBlendMode("replace")
	love.graphics.setColor(0,0,0,0)
	love.graphics.rectangle("fill",0,(line-1)*lib.charSize.h,self.bounds.w,lib.charSize.h)
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(br,bg,bb,ba)
	love.graphics.print(self.txt[line],0,(line-1)*lib.charSize.h)
	love.graphics.setCanvas(canv);love.graphics.setFont(font);love.graphics.setColor(br,bg,bb,ba);love.graphics.setBlendMode(blendMode,alphaBM)
end

function ex.draw(self)
	love.graphics.draw(self.canv,self.bounds.x,self.bounds.y)
	for i,v in ipairs(self.cars) do
		love.graphics.rectangle("fill",self.bounds.x+v.x*lib.charSize.w,self.bounds.y+v.y*lib.charSize.h,1,lib.charSize.h)
	end
end

function ex.keypressed(self,key)
	if key=="left" then for i,v in ipairs(self.cars) do v:move(-1,0,self.txt) end end
	if key=="right" then for i,v in ipairs(self.cars) do v:move(1,0,self.txt) end end
	if key=="up" then for i,v in ipairs(self.cars) do v:move(0,-1,self.txt) end end
	if key=="down" then for i,v in ipairs(self.cars) do v:move(0,1,self.txt) end end
	if key=="backspace" then for i,v in ipairs(self.cars) do v:del(-1,self.txt,self.redrawLines) end end
	if key=="delete" then for i,v in ipairs(self.cars) do v:del(1,self.txt,self.redrawLines) end end
	if key=="home" then for i,v in ipairs(self.cars) do v.x=0 end end
	if key=="end" then for i,v in ipairs(self.cars) do v.x=#self.txt[v.y+1] end end
	if key=="return" then for i,v in ipairs(self.cars) do v:newLine(self.txt,self.redrawLines) end end
	self:redraw(self.redrawLines)
end

function ex.textinput(self,txt)
	for i,v in ipairs(self.cars) do
		v:insert(txt,self.txt,self.redrawLines)
	end
	self:redraw(self.redrawLines)
end

function ex.mousepressed(self,x,y,b)
	if b=="l" then
		if #self.cars>1 or not self.cars[1] then
			self.cars = {caret.new(math.floor((x-self.bounds.x)/lib.charSize.w+0.5),math.floor((y-self.bounds.y)/lib.charSize.h+0.5),self.txt)}
		else
			self.cars[1]:set(math.floor((x-self.bounds.x)/lib.charSize.w+0.5),math.floor((y-self.bounds.y)/lib.charSize.h+0.5),self.txt)
		end
	end
end

function ex.mousemoved(self,x,y,dx,dy)
	if love.mouse.isDown("l") then
		if #self.cars>1 or not self.cars[1] then
			self.cars = {caret.new(math.floor((x-self.bounds.x)/lib.charSize.w+0.5),math.floor((y-self.bounds.y)/lib.charSize.h+0.5),self.txt)}
		else
			self.cars[1]:set(math.floor((x-self.bounds.x)/lib.charSize.w+0.5),math.floor((y-self.bounds.y)/lib.charSize.h+0.5),self.txt)
		end
	end
end

function ex.mousereleased(self,x,y,b)
	if b=="l" then
		if #self.cars>1 or not self.cars[1] then
			self.cars = {caret.new(math.floor((x-self.bounds.x)/lib.charSize.w+0.5),math.floor((y-self.bounds.y)/lib.charSize.h+0.5),self.txt)}
		else
			self.cars[1]:set(math.floor((x-self.bounds.x)/lib.charSize.w+0.5),math.floor((y-self.bounds.y)/lib.charSize.h+0.5),self.txt)
		end
	end
end

-- ========================================== lib obj

lib.ex = ex

function meta.__call(t,x,y,w,h)
	return setmetatable({bounds=Rec(x,y,w,h)},{__index=t.ex})
end

setmetatable(lib,meta)

return lib