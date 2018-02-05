_VECTOR = _VECTOR or require("libs/Vec")("Vec","Vector")
_RECTANGLE = _RECTANGLE or require("libs/Rec")("Rec","Rect","Rectangle")
_LINE = _LINE or require("libs/Line")("Line")
local frameRect = require("libs/frameRect")

-- forward declaration
local elementRenderers
local frameRenderers

-- ========================================== UI Element class
local element = {}
	element.dims = Rec(0,0,0,0)
	element.imgs = {}
	element.type = "Rect" -- many possible: Rect, Text, List, Ellipse, SpriteRect, Sprite, Line, EditorCanvas, Frame, Polygon
	element.options = {fill = true,resDep = false}
		-- type-specific options - some types may have required options.
		-- Rect
			-- fill = bool; first arg passed to love.graphics.rectangle
		-- Text
			-- font = font obj, size = number, scale = number
		-- List
			-- endless = bool, scrollup = list { string }, scrolldn = list { string }
		-- Ellipse
		-- SpriteRect
		-- Sprite
		-- Line
		-- EditorCanvas
		-- Frame
		-- Polygon
	element.color = {255,255,255,255}
	element.eatClick = true
	element.clickOverride = false
	element.data = {}
	-- methods
	element.copy = function(self) end
	-- callbacks
	element.clicked = function(self,x,y,b,consumed) end
	--element.??? = function(self,x,y,dx,dy,consumed) end -- unsure how I want to implement this.
	element.released = function(self,x,y,b,consumed) end
	element.subClicked = function (self,x,y,b,consumed) end
	element.subReleased = function (self,x,y,b,consumed) end
	--element.scroll = function (self,dx,dy,consumed) end
	element.drawSub = function (self,i,x,y,data) end

-- ========================================== UI Frame class
local frame = {}
	frame.dims = Rec(0,0,0,0)
	frame.elements = {}
	frame.type = "SpriteRect" -- possible: Fill, Line, Full, Tile, SpriteRect
	frame.canvas = nil
	frame.internalOffset = true
	frame.resDep = true
	frame.color={255,255,255,255}
	frame.color2 = {0,0,0,255}
	frame.sprite = love.graphics.newImage("stockData/tiles/defaultBlock.png")
	frame.sprites = {
		T = love.graphics.newImage("stockData/UI/UI2_border1_T.png"),
		B = love.graphics.newImage("stockData/UI/UI2_border1_B.png"),
		L = love.graphics.newImage("stockData/UI/UI2_border1_L.png"),
		R = love.graphics.newImage("stockData/UI/UI2_border1_R.png"),
		TL = love.graphics.newImage("stockData/UI/UI2_border1_TL.png"),
		TR = love.graphics.newImage("stockData/UI/UI2_border1_TR.png"),
		BL = love.graphics.newImage("stockData/UI/UI2_border1_BL.png"),
		BR = love.graphics.newImage("stockData/UI/UI2_border1_BR.png"),
		BG = love.graphics.newImage("stockData/UI/UI2_backg_color.png")
	}
	frame.innerOffset = true

	function frame.draw(self,...)
		if frameRenderers[self.type] then
			frameRenderers[self.type](self,...)
		end
	end

-- ========================================== Helper functions for drawing and resolution independance

local function resDepRec(rect)
	return rect.x*love.graphics.getWidth(),rect.y*love.graphics.getHeight(),rect.w*love.graphics.getWidth(),rect.h*love.graphics.getHeight()
end
local function unResDepRec(rect)
	return rect.x/love.graphics.getWidth(),rect.y/love.graphics.getHeight(),rect.w/love.graphics.getWidth(),rect.h/love.graphics.getHeight()
end
-- ==========================================
frameRenderers = {}
function frame.renderElements(self)
	for i,v in ipairs(self.elements) do
		if elementRenderers[v.type] then
			elementRenderers[v.type](self,v)
		end
	end
end
function frameRenderers.Fill(self)
	local r,g,b,a = love.graphics.getColor()
	local sx,sy,sw,sh = love.graphics.getScissor()
	love.graphics.intersectScissor(unpack(self.dims))
	love.graphics.setColor(unpack(self.color))
	if self.resDep then
		love.graphics.rectangle("fill",unpack(self.dims))
	else
		love.graphics.rectangle("fill",resDepRec(self.dims))
	end
	love.graphics.setColor(r,g,b,a)
	self:renderElements()
	love.graphics.setColor(r,g,b,a)
	love.graphics.setScissor(sx,sy,sw,sh)
end
function frameRenderers.Line(self)
	local r,g,b,a = love.graphics.getColor()
	local sx,sy,sw,sh = love.graphics.getScissor()
	love.graphics.intersectScissor(unpack(self.dims))
	self:renderElements()
	love.graphics.setColor(unpack(self.color))

	if self.resDep then
		love.graphics.rectangle("line",unpack(self.dims))
	else
		love.graphics.rectangle("line",resDepRec(self.dims))
	end
	love.graphics.setColor(r,g,b,a)
	love.graphics.setScissor(sx,sy,sw,sh)
end
function frameRenderers.Full(self)
	local r,g,b,a = love.graphics.getColor()
	local sx,sy,sw,sh = love.graphics.getScissor()
	love.graphics.intersectScissor(unpack(self.dims))
	love.graphics.setColor(unpack(self.color2))

	if self.resDep then
		love.graphics.rectangle("fill",unpack(self.dims))
	else
		love.graphics.rectangle("fill",resDepRec(self.dims))
	end
	love.graphics.setColor(r,g,b,a)
	self:renderElements()
	love.graphics.setColor(unpack(self.color))
	if self.resDep then
		love.graphics.rectangle("line",unpack(self.dims))
	else
		love.graphics.rectangle("line",resDepRec(self.dims))
	end

	love.graphics.setColor(r,g,b,a)
	love.graphics.setScissor(sx,sy,sw,sh)
end
function frameRenderers.Tile(self,ox,oy,scale)
	local r,g,b,a = love.graphics.getColor()
	local sx,sy,sw,sh = love.graphics.getScissor()
	love.graphics.intersectScissor(unpack(self.dims))
	scale = scale or 1
	ox = ox or 0
	oy = oy or 0
	love.graphics.setColor(unpack(self.color))
	local dims

	local fx,fy,fw,fh
	if not self.resDep then
		fx,fy,fw,fh = resDepRec(self.dims)
	else
		fx,fy,fw,fh = unpack(self.dims)
	end
	fx = fx * scale; fy = fy * scale; fw = fw * scale; fh = fh * scale
	for x=fx,fw+self.sprite:getWidth()*scale,self.sprite:getWidth()*scale do
		for y=fy,fh+self.sprite:getHeight()*scale,self.sprite:getHeight()*scale do
			love.graphics.draw(self.sprite,x-ox*self.sprite:getWidth()*scale,y-oy*self.sprite:getHeight()*scale,0,scale,scale)
		end
	end

	love.graphics.setColor(r,g,b,a)
	self:renderElements()
	love.graphics.setScissor(sx,sy,sw,sh)
end
function frameRenderers.SpriteRect(self,innerOffset,bgRep,outside,rep,scale)
	scale = scale or self.spriteScale or 1
	if outside ~= nil then outside = outside elseif self.outside ~= nil then outside = self.outside else outside = false end
	if rep ~= nil then rep = rep elseif self.rep ~= nil then rep = self.rep else rep = true end
	if bgRep ~= nil then bgRep = bgRep elseif self.bgRep ~= nil then bgRep = self.bgRep else bgRep = false end
	if innerOffset ~= nil then innerOffset = innerOffset elseif self.innerOffset ~= nil then innerOffset = self.innerOffset else innerOffset = false end
	local dims
	if self.resDep then
		dims = self.dims:copy()
	else
		dims = _RECTANGLE(resDepRec(dims))
	end

	local sx,sy,sw,sh = love.graphics.getScissor()
	if outside then
		love.graphics.intersectScissor(unpack(dims))
		if bgRep then
		else
			love.graphics.draw(self.sprites.BG,dims.x,dims.y,0,dims.w/self.sprites.BG:getWidth(),dims.h/self.sprites.BG:getHeight())
		end
	else
		local interiorDims = _RECTANGLE(
				dims.x+self.sprites.TL:getWidth()*scale,
				dims.y+self.sprites.TL:getHeight()*scale,
				dims.w-(self.sprites.TL:getWidth()+self.sprites.BR:getWidth())*scale,
				dims.h-(self.sprites.TL:getHeight()+self.sprites.BR:getHeight())*scale
			)
		local oldDims = self.dims
		if innerOffset then
			if self.resDep then
				self.dims = interiorDims
			else
				self.dims = _RECTANGLE(unResDepRec(interiorDims))
			end
		end
		love.graphics.intersectScissor(unpack(interiorDims))

		if bgRep then
			for x = interiorDims.x, interiorDims.r, self.sprites.BG:getWidth()*scale do
				for y = interiorDims.y, interiorDims.b, self.sprites.BG:getHeight()*scale do
					love.graphics.draw(self.sprites.BG,x,y,0,scale,scale)
				end
			end
		else
			love.graphics.draw(self.sprites.BG,interiorDims.x,interiorDims.y,0,interiorDims.w/(self.sprites.BG:getWidth()*scale),interiorDims.h/(self.sprites.BG:getHeight()*scale))
		end

		self:renderElements()

		if innerOffset then
			if self.resDep then
				interiorDims:del()
				self.dims = oldDims
			else
				self.dims:del()
				self.dims = oldDims
			end
		end
	end
	love.graphics.setScissor(sx,sy,sw,sh)

	frameRect(dims,self.sprites.TL,self.sprites.TR,self.sprites.BL,self.sprites.BR,self.sprites.T,self.sprites.L,self.sprites.B,self.sprites.R,outside,rep,scale,scale)
	dims:del()
end
-- ==========================================
elementRenderers = {}
function elementRenderers.getRelativeDims(frame,element,resDep,gw,gh)
	gw = gw or love.graphics.getWidth()
	gh = gh or love.graphics.getHeight()
	local x,y,w,h = unpack(element.dims)
	local fx,fy,fw,fh = unpack(frame.dims)
	-- convert units to standard non resdep
		if frame.resDep then
			fx = fx / gw
			fy = fy / gh
			fw = fw / gw
			fh = fh / gh
		end
		if element.options.resDep then
			x = x / gw
			y = y / gh
			w = w / gw
			h = h / gh
		else
			-- frame internal positioning
			x = x * fw
			y = y * fh
			w = w * fw
			h = h * fh
		end
	-- I guess this is a thing??
		if not frame.internalOffset then
			x = x - fx
			y = y - fy
		else
			x = x + fx
			y = y + fy
		end
	if resDep then
		x = x * gw
		y = y * gh
		w = w * gw
		h = h * gh
	end
	return x,y,w,h
end
local relDims = elementRenderers.getRelativeDims

function elementRenderers.Rect(frame,element)
	local prevR,prevG,prevB,prevA = love.graphics.getColor()
	love.graphics.setColor(unpack(element.color))
	print(elementRenderers.getRelativeDims(frame,element,element.resDep))
	love.graphics.rectangle(element.options.fill and "fill" or "line",elementRenderers.getRelativeDims(frame,element,true))
end
function elementRenderers.Text(frame,element)
	local scale = element.scale or 1
	if not element.options.size then
		element.options.size = 12
	end
	if not element.options.font or element._LASTSIZE~=element.options.size then
		element.options.font = love.graphics.newFont(element.options.size)
		element._LASTSIZE = element.options.size
	end
	local x,y,w,h = elementRenderers.getRelativeDims(frame,element,element.resDep)
	love.graphics.Scale(scale)
	love.graphics.print(element.text or "",x/scale,y/scale)
	love.graphcis.Scale(1/scale)
end

-- ==========================================
function element.new(data)
	return setmetatable(data,{__index = element})
end
function frame.new(data)
	data.elements = {}
	return setmetatable(data,{__index = frame})
end

return function() return element,frame end