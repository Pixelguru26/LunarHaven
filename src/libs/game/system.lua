local lib = {}

function lib.enableUI(name)
	if UIMngr[name] and not enabledUIs[name] then
		enabledUIs[name]=UIMngr[name]
		table.insert(enabledUIs,UIMngr[name])
		enabledUIs[name].load( name )
	end
end
function lib.disableUI(name)
	if enabledUIs[name].exit then
		enabledUIs[name].exit()
	end
	enabledUIs[name]=nil
	for i,v in ipairs(enabledUIs) do
		if v==UIMngr[name] then
			table.remove(enabledUIs,i)
		end
	end
end

function lib.disableAllUIs()
	enabledUIS = {}
end

function lib.isUIEnabled(name)
	for k,v in pairs(enabledUIs) do
		if k==name then return true end
	end
	return false
end

function lib.saveGFXState()
	return {
		love.graphics.getBackgroundColor(),
		love.graphics.getBlendMode(),
		love.graphics.getCanvas(),
		love.graphics.getColor(),
		love.graphics.getColorMask(),
		love.graphics.getDefaultFilter(),
		love.graphics.getLineJoin(),
		love.graphics.getLineStyle(),
		love.graphics.getLineWidth(),
		love.graphics.getShader(),
		love.graphics.getPointSize(),
		love.graphics.getScissor(),
		love.graphics.isWireframe()
	}
end
function lib.restoreGFXState(state)
	love.graphics.setBackgroundColor(state[1],state[2],state[3],state[4])
	love.graphics.setBlendMode(state[5],state[6])
	love.graphics.setCanvas(state[7])
	love.graphics.setColor(state[8],state[9],state[10],state[11])
	love.graphics.setColorMask(state[12],state[13],state[14],state[15])
	love.graphics.setDefaultFilter(state[16],state[17],state[18])
	love.graphics.setLineJoin(state[19])
	love.graphics.setLineStyle(state[20])
	love.graphics.setLineWidth(state[21])
	love.graphics.setShader(state[22])
	love.graphics.setPointSize(state[23])
	love.graphics.setScissor(state[24],state[25],state[26],state[27])
	love.graphics.setWireframe(state[28])
end

local function tableToDirTree(t,dir)
	love.filesystem.createDirectory(dir)
	for k,v in pairs(t) do
		if type(v)=="table" then
			if v.isFile then
				if v.fileType=="lua" then
					love.filesystem.write(dir.."/"..k..".lua",v.data)
				elseif v.fileType=="json" then
					love.filesystem.write(dir.."/"..k..".json",json.encode(v.data))
				elseif v.fileType=="txt" then
					love.filesystem.write(dir.."/"..k..".lua",v.data)
				else
					love.filesystem.write(dir.."/"..k,v.data)
				end
			else
				tableToDirTree(v,dir.."/"..k)
			end
		end
	end
end
local saveDirStructure = {
	Player = {
		Inventory = {
			unsorted = {
				__layout = {
					isFile = true,
					fileType = "json",
					data = {
						sorting = "index", -- possible: index, name, type, grid, floating
						positions = {[1]={0,0}}
					}
				}
			},
			desktop = {
				__layout = {
					isFile = true,
					fileType = "json",
					data = {
						sorting = "grid", -- possible: index, name, type, grid, floating
						positions = {[1]={0,0}}
					}
				}
			},
			UI = {
				__layout = {
					isFile = true,
					fileType = "json",
					data = {
						sorting = "index",
						positions = {[1]={0,0}}
					}
				}
			}
		},
		__meta = {
			isFile = true,
			fileType = "json",
			data = {
				name = "Philipp",
				recent = {"default","1"}
			}
		}
	},
	Cache = {
		default = {
			[1] = {
				-- this represents a "default" player, the storage for stock items.
				__meta = {
					isFile = true,
					fileType = "json",
					data = {
						name = "Lunar Haven Dev Team",
						status = "Don't mind me, I'm just tinkering with the fabric of time and space for your enjoyment.",
						rank = 0,
						integrity = 99
					}
				}
			}
		}
	}
}
function lib.createSaveDir()
	tableToDirTree(saveDirStructure,"")
end

return lib