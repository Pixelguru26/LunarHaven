-- ========================================== simple utils

	function gw()
		return love.graphics.getWidth()
	end

	function gh()
		return love.graphics.getHeight()
	end

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

-- ========================================== number rounding blah blah blah

	function math.round(v)
		return math.floor(v+0.5)
	end

-- ========================================== math crap
	function returnIfPositive(v)
		return v>=0 and v or nil
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
		return math.min(x,math.max(v,n))
	end

	function math.Lerp(v,a,b)
		return a+v*(b-a)
	end

	function quickRead(iput,indent)
		indent = indent or ""
		local result={}
		for k,v in pairs(iput) do
			if type(v)=="table" then
				table.insert(result,indent.."{"..k..": \n")
				table.insert(result,quickRead(iput,indent.."\t"))
				table.insert(result,indent.."}\n")
			else
				table.insert(result,indent.."["..k..": "..v.."]\n")
			end
		end
		return table.concat(result)
	end
