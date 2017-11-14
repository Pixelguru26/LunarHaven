lib={} -- standard library container/class/table/module/whateveryouwannacallit

lib.defaultFont = love.graphics.getFont() -- yeah, we need it :P

lib.exampolygon = 
	{
			-- polygon class
		--options
			color = {100,255,180,255},
			mode = "fill",
			origin = {0,0},
		--points
			[1] = 72,
			[2] = 0,
			[3] = 128,
			[4] = 128,
			[5] = 0,
			[6] = 128
	}
lib.example = 
	{
			-- managed element class
		-- options
	doBaseOffset = true,
	drawOnResize = false,
	disabled = false,
		-- data
	name = "simplexample",
	bounds = Rect(0,0,128,30),
	subsOffset = Vec(2,32),
	color = {180,180,180,255},
		-- visuals
	drawRects = {Rect(0,0,128,30),Rect(0,30,128,128,{color={100,100,100,255}})},
	drawShapes = {},
	drawSprites = {},
	drawTexts = {{"Peep ~",bounds = Rect(2,2,124,26),color={60,60,60,255}}},
		-- declaration
	subs = {
		{
				-- options
			doBaseOffset = true,
			simple = true,
				-- data
			name = "simplesub",
			bounds = Rect(0,0,28,28),
			color = {180,180,180,255},
				-- visuals
			drawRects = {Rect(0,0,28,28)},
				-- functions
			mousepressed = function(self,x,y,button,ox,oy) if (Vec(x,y):isWithinRec(self.bounds)) then self.color = {180,255,220,255} end end
		}
	},
		-- functions
	load = function(self) self.dragging = false end,
	update = function(self,dt) end,
	mousepressed = function(self,x,y,button,unConsumed,ox,oy) if (Vec(x,y):isWithinRec(self.bounds)) then self.dragging = true; return false end return true end,
	mousereleased = function(self,x,y,button,unConsumed,ox,oy) self.dragging = false; return not (Vec(x,y):isWithinRec(self.bounds)) end,
	mousemoved = function(self,x,y,dx,dy,ox,oy) if self.dragging then self.bounds.pos = self.bounds.pos + Vec(dx,dy) end end,
	resize = function(self,width,height) end,
	draw = function(self,canv,elements,offset) end
}

lib.elements={} -- container for all ui element instances

function lib.load(elements,parent) -- load elements list
	lib.dt = 0
	local elements = elements or lib.elements
	for index,element in ipairs(elements) do
		if not element.disabled then
			if element.load then element:load(parent,index) end
			if element.subs then
				lib.load(element.subs,element)
			end
		end
	end
	if not parent then
		lib.resize(gw(),gh())
	end
end

function lib.update(dt,elements,parent) -- update every frame
	lib.dt = dt
	local elements = elements or lib.elements -- defaulting
	for index,element in ipairs(elements) do
		if not element.disabled then
			if element.update then
				element:update(dt)
			end
			if element.subs then
				lib.update(dt,element.subs,element)
			end
		end
	end
end

-- UI manager core rendering function
--
-- canv: render target
-- elements (optional): list of elements to render. Defaults to lib.elements
-- offset (optional): compounding offset vector for proper sub rendering
function lib.draw(canv,elements,offset,parent)
	if not canv then return "function requires access to render target as first arg!" end -- canv is a necessity!
	local elements = elements or lib.elements -- defaulting
	local offset = offset or Vec(0,0) -- defaulting offset


	for index,element in ipairs(elements) do -- iterate over elements and draw
		if not element.disabled and not element.invisible then
			love.graphics.setCanvas(canv) -- implement canv
			love.graphics.setColor(unpack(element.color)) -- for every element, the element's color is default.

			-- "simple" element renderer

			-- "resolving" :P
				-- necessary for dynamic elements
				if element.resolve then
					element:resolve(canv,elements,offset,parent)
				end
			-- rectangle rendering
				if element.drawRects then
					for i,v in ipairs(element.drawRects) do
						if v.color then -- rectangles kinda need their own color too :P
							love.graphics.setColor(v.color[1] or 255,v.color[2] or 255,v.color[3] or 255,v.color[4] or 255)
						else
							love.graphics.setColor(unpack(element.color))
						end
						love.graphics.rectangle(v.mode or "fill",v.x+offset.x+element.bounds.x,v.y+offset.y+element.bounds.y,v.w,v.h)
					end
				end
				love.graphics.setColor(unpack(element.color)) -- clear colors
			-- polygon rendering
				love.graphics.translate(offset.x+element.bounds.x,offset.y+element.bounds.y) -- apply offset
				if element.drawShapes then
					for i,v in ipairs(element.drawShapes) do
						if v.origin then love.graphics.translate(v.origin.x,v.origin.y) end
						if v.color then love.graphics.setColor(unpack(v.color)) else love.graphics.setColor(element.color) end -- polygons get individual colors
						love.graphics.polygon(v.mode or "fill",v)
						if v.origin then love.graphics.translate(-v.origin.x,-v.origin.y) end
					end
					love.graphics.setColor(unpack(element.color)) -- reset from polygon colors
				end
				love.graphics.translate(-offset.x-element.bounds.x,-offset.y-element.bounds.y) -- reset parental offset
			-- sprite rendering
				if element.drawSprites then
					love.graphics.setColor(255,255,255,255)
					for i,v in ipairs(element.drawSprites) do
						love.graphics.draw(v[1],v[2]+offset.x+element.bounds.x,v[3]+offset.y+element.bounds.y,v[4] or 0,v[5] or 1,v[6] or 1)
					end
				end
			-- text rendering
				if element.drawTexts then
					for i,v in ipairs(element.drawTexts) do
						if v.color then love.graphics.setColor(unpack(v.color)) else love.graphics.setColor(unpack(element.color)) end
						if v.font then love.graphics.setFont(v.font[1]) else love.graphics.setFont(lib.defaultFont) end
						if not v.noscissor then love.graphics.setScissor(v.bounds.x+offset.x+element.bounds.x,v.bounds.y+offset.y+element.bounds.y,v.bounds.w,v.bounds.h) end
						if not v.noscissor and love.graphics.getFont():getWidth(v[1]) > v.bounds.w then 
							v._REND_X = v._REND_X and v._REND_X - v.bounds.w or nil
							v._REND_X = ((v._REND_X or -v.bounds.w) - lib.dt * 20) % -(love.graphics.getFont():getWidth(v[1])+v.bounds.w)
							v._REND_X = v._REND_X + v.bounds.w
						end
						love.graphics.print(v[1],v.bounds.x+offset.x+element.bounds.x+(v._REND_X or 0),v.bounds.y+offset.y+element.bounds.y)
						love.graphics.setScissor()
					end
				end -- RENDER TEXT
			-- advanced drawing
				if (not element.drawOnResize or element.redraw) and element.draw then
					love.graphics.setColor(unpack(element.color))
					element:draw(canv,elements,offset,parent) -- I'm going to depend on element draw functions to reset their own changes.
				end
			-- sub elements
				if element.subs then
					for i,v in ipairs(element.subs) do
						v.redraw = v.redraw or element.redraw
					end
					lib.draw(canv,element.subs,offset+element.subsOffset+(element.doBaseOffset and Vec(element.bounds.x,element.bounds.y) or 0),element)
				end
			element.redraw = nil
		end
	end

	love.graphics.setCanvas()
end

-- ========================================== "etc()" functions

function lib.mousepressed(x,y,b,elements,offset,unConsumed,parentallyConsumed,parent)
	local elements = elements or lib.elements
	local offset = offset or Vec(0,0)
	if unConsumed==nil then
		unConsumed = true
	end

	for index,element in rpairs(elements) do
		if not element.disabled then
			local pC = false
			if element.mousepressed and not element.lastClicked then
				-- temporarily store unconsumed from element click
				local uc = element:mousepressed(x-offset.x,y-offset.y,b,unConsumed,parentallyConsumed,offset.x,offset.y,parent)
				pC = (not uc) and unConsumed -- if unconsumed then parentally consumed is false, but if consumed parentally consumed is true; also cannot be previously consumed
				unConsumed = unConsumed and uc -- element cannot turn unconsumed back to true
			end
			if element.subs then
				local uc = lib.mousepressed(x,y,b,element.subs,offset+element.subsOffset+(element.doBaseOffset and element.bounds.pos or Vec(0,0)),unConsumed,pC,element)
				unConsumed = unConsumed and uc
			end
			if element.mousepressed and element.lastClicked then
				-- temporarily store unconsumed from element click
				local uc = element:mousepressed(x-offset.x,y-offset.y,b,unConsumed,parentallyConsumed,offset.x,offset.y,parent)
				unConsumed = unConsumed and uc -- element cannot turn unconsumed back to true
			end
		end
	end
	return unConsumed
end

function lib.mousemoved(x,y,dx,dy,elements,offset,parent)
	local elements = elements or lib.elements
	local offset = offset or Vec(0,0)

	for index,element in rpairs(elements) do
		if not element.disabled then
			if element.mousemoved then
				element:mousemoved(x-offset.x,y-offset.y,dx,dy,offset.x,offset.y)
			end
			if element.subs then
				lib.mousemoved(x,y,dx,dy,element.subs,offset+element.subsOffset+(element.doBaseOffset and element.bounds.pos or Vec(0,0)),parent)
			end
		end
	end
end

function lib.mousereleased(x,y,b,elements,offset,unConsumed,parentallyConsumed,parent)
	local elements = elements or lib.elements
	local offset = offset or Vec(0,0)
	local unConsumed = (unConsumed~=nil and unConsumed) or true

	for index,element in rpairs(elements) do
		if not element.disabled then
			local parentallyConsumed = false
			if element.mousereleased then
				local uc = element.mousereleased(element,x-offset.x,y-offset.y,b,unConsumed,false,offset.x,offset.y)
				parentallyConsumed = not (unConsumed and uc)
				unConsumed = unConsumed and uc
			end
			if element.subs then
				unConsumed = unConsumed and lib.mousereleased(x,y,b,element.subs,offset+element.subsOffset+(element.doBaseOffset and element.bounds.pos or Vec(0,0)),unConsumed,parentallyConsumed,element)
			end
		end
	end
	return unConsumed
end

-- parentalOnly is a boolean for when changes are to pw and ph; 
-- parental width and parental height respectively.
function lib.resize(w,h,elements,parentalOnly,pw,ph,parent,offset) -- resize
	-- NON STANDARD SECTION
	if not parent then
		--font sizes
		for k,v in pairs(fonts) do
			if type(v)=="table" then -- make sure we're fixing an actual font here. Not perfect, but better than nothing
				v[1] = love.graphics.newFont(v.size*cmRat)
			end
		end
	end
	-- /nonstandard
	local elements = elements or lib.elements
	local offset = offset or Vec(0,0)
	for index,element in ipairs(elements) do
		if not element.disabled then
			if element.resize then element:resize(w,h,parentalOnly,pw,ph,parent,offset) end
			if element.drawOnResize then element:draw(canv,elements,offset,parent) end
			if element.subs then
				lib.resize(w,h,element.subs,false,element.bounds.w,element.bounds.h,element,offset+element.subsOffset+(element.doBaseOffset and Vec(element.bounds.x,element.bounds.y) or 0))
			end
		end
	end
end

function lib.keypressed(k,elements,parent)
	local elements = elements or lib.elements
	for index, element in ipairs(elements) do
		if not element.disabled then
			if element.keypressed then element:keypressed(k) end
			if element.subs then
				lib.keypressed(k,element.subs,element)
			end
		end
	end
end

function lib.keyreleased(k,elements,parent)
	local elements = elements or lib.elements
	for index, element in ipairs(elements) do
		if not element.disabled then
			if element.keyreleased then element:keyreleased(k) end
			if element.subs then
				lib.keyreleased(k,element.subs,element)
			end
		end
	end
end

function lib.quit(elements,parent)
	local elements = elements or lib.elements
	for index,element in ipairs(elements) do
		if not element.disabled then
			if element.subs then
				lib.quit(element.subs,parent)
			end
			if element.quit then element:quit() end
		end
	end
end

return lib