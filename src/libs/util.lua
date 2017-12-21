-- ========================================== simple utils

	gw = love.graphics.getWidth

	gh = love.graphics.getHeight

	local function rter (t, i)
		i = i - 1
		local v = t[i]
		if v then
			return i, v
		end
	end
	
	function rpairs (t)
		return rter, t, #t+1
	end

-- ========================================== math crap

	function math.sMin(a,b)
		return a<b and a or b
	end
	function math.sMin(a,b)
		return a>b and a or b
	end

	function math.round(v)
		return math.floor(v+0.5)
	end

	function returnIfPositive(v)
		return v>=0 and v or nil
	end

	function math.Sign(v)
		return v>0 and 1 or v<0 and -1 or 0
	end

	function isWithin(a,b,c)
		return a>=b and a<=c
	end

	function isWithin2D(aa,ab,ba,bb,ca,cb)
		return isWithin(aa,ba,ca) and isWithin(ab,bb,cb)
	end

	function math.setSign(v,s)
		if v~=0 then
			return s==-1 and -math.abs(v) or math.abs(v)
		else
			return v
		end
	end

	function math.Limit(v,n,x)
		return v < n and n or (v > x and x or v)
	end

	function math.Lerp(v,a,b)
		return a+v*(b-a)
	end

	function math.maxIndex(...)
		local l = {...}
		local mI = 1
		for i,v in ipairs(l) do
			mI=v>l[mI] and i or mI
		end
		return mI
	end
	function math.minIndex(...)
		local l = {...}
		local mI = 1
		for i,v in ipairs(l) do
			mI=v<l[mI] and i or mI
		end
		return mI
	end
	function math.absMaxIndex(...)
		local l = {...}
		local mI = 1
		for i,v in ipairs(l) do
			mI=math.abs(v)>math.abs(l[mI]) and i or mI
		end
		return mI
	end
	function math.absMinIndex(...)
		local l = {...}
		local mI = 1
		for i,v in ipairs(l) do
			mI=math.abs(v)<math.abs(l[mI]) and i or mI
		end
		return mI
	end
	function math.wrap(v,n,m)
		return ((v-n)%(m-n))+n
	end

	-- ========================================== Other stuff

	-- general coordinate set iterator
	local function coord_iter(t,i)
		return t[i+2] and i+2 or nil,t[i+1],t[i+2]
	end
	function icoords(t)
		return coord_iter,t,0
	end

	-- bresenham line algorithm iterator
	-- local function bresenham_iter(s)
	-- 	local dx, dy = s[3]-s[1], s[4]-s[2]
	-- 	if s[6]==0 then
	-- 		return nil
	-- 	end
	-- 	if s[5] > s[6] then
	-- 		s[5] = s[5] - s[6]
	-- 		s[8] = s[8] + math.Sign(dy)
	-- 	elseif math.abs(s[7]-s[1]) < math.abs(dx) then
	-- 		s[7] = s[7] + math.Sign(dx)
	-- 		s[5] = s[5] + math.abs(dy)
	-- 	else
	-- 		return nil
	-- 	end
	-- 	return s[7],s[8]
	-- end
	function bresenham(x1,y1,x2,y2)
		-- x1, y1, x2, y2, error, error divisor, current x, current y, lastType
		-- return bresenham_iter,{math.floor(x1),math.floor(y1),math.floor(x2),math.floor(y2),0,math.abs(x2-x1),math.floor(x1),math.floor(y1),"h"},x1,y1
		local ix1 = math.floor(x1)
		local ix2 = math.floor(x2)
		local iy1 = math.ceil(y1)
		local iy2 = math.ceil(y2)
		local y,err,errDiv,plot = y1,0,math.abs(x2-x1),{}
		if math.floor(x1) == math.floor(x2) and math.floor(y1) == math.floor(y2) then
			return icoords({math.floor(x1),math.floor(y1)})
		end
		if errDiv ~= 0 then
			for x=math.floor(x1),math.floor(x2),math.Sign(x2-x1) do
				while err > errDiv do
					--print(x,y,"v")
					err = err - errDiv
					y = y + math.Sign(y2-y1)
					if (x>=ix1 and x<=ix2) or (x<=ix1 and x>=ix2) and (y>=iy1 and y<=iy2) and (y<=iy1 and y>=iy2) then
						table.insert(plot,x)
						table.insert(plot,y)
					end
				end
				--print(x,y,"h")
				if (x>=ix1 and x<=ix2) or (x<=ix1 and x>=ix2) and (y>=iy1 and y<=iy2) and (y<=iy1 and y>=iy2) then
					table.insert(plot,x)
					table.insert(plot,y)
				end
				err = err + math.abs(y2-y1)
			end
		else
			for y=y1,y2,math.Sign(y2-y1) do
				if (y>=iy1 and y<=iy2) and (y<=iy1 and y>=iy2) then
					table.insert(plot,x1)
					table.insert(plot,y)
				end
			end
		end
		return icoords(plot)
	end

	-- simple (and bad) table "serializer" for simple debugging
	function quickRead(iput,indent,depth)
		depth = (depth or 5)-1
		indent = indent or ""
		local result={}
		for k,v in pairs(iput) do
			if type(v)=="table" then
				if depth > 0 then
					table.insert(result,indent..k..": {\n")
					table.insert(result,quickRead(iput,indent.."\t",depth))
					table.insert(result,indent.."}\n")
				else
					table.insert(result,indent..k..": "..tostring(v).."\n")
				end
			else
				table.insert(result,indent.."["..k..": "..tostring(v).."]\n")
			end
		end
		return table.concat(result)
	end