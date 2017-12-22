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
	if enabledUIs[name] then
		return true
	else
		return false
	end
end

function lib.getUI(name)
	return enabledUIs[name]
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
				elseif v.fileType=="copy" then
					local data = love.filesystem.read(v.data)
					love.filesystem.write(dir.."/"..k,data)
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
				},
				["ffd7d9dd-ead6-471f-afdb-5a6de7b9de59"] = {
					frames = {
						["tile.png"] = {isFile = true, fileType = "copy", data = "stockData/tiles/defaultBlock.png"}
					},
					assets = {},
					settings = {
						isFile = true,
						fileType = "json",
						data = {
							name = "testBlock",
							type = "Tile",
							layer = 4,
							solid = true
						}
					}
				},
				["b9882349-379e-4b07-8464-c0c8dc027273"] = {
					frames = {
						["tile.png"] = {isFile = true, fileType = "copy", data = "stockData/tiles/defaultBlock.png"}
					},
					assets = {},
					settings = {
						isFile = true,
						fileType = "json",
						data = {
							name = "Default",
							type = "Tile",
							layer = 4,
							solid = true
						}
					}
				},
				["c1f0aca7-86aa-4992-8de3-d6f93f6fe2e5"] = {
					frames = {
						["tile.png"] = {isFile = true, fileType = "copy", data = "stockData/tiles/defaultBGBlock.png"}
					},
					assets = {},
					settings = {
						isFile = true,
						fileType = "json",
						data = {
							name = "Default BG",
							type = "Tile",
							layer = 0,
							solid = false
						}
					}
				},
				["e804c749-bd74-4d64-877c-3fd2537c0117"] = {
					frames = {
						["tile.png"] = {isFile = true, fileType = "copy", data = "stockData/tiles/pillarBlock.png"}
					},
					assets = {},
					settings = {
						isFile = true,
						fileType = "json",
						data = {
							name = "FG Test",
							type = "Tile",
							layer = 4,
							solid = false
						}
					}
				},
				["925201d2-23f4-444c-be7b-40d3c3d09296"] = {
					frames = {
						["tile.png"] = {isFile = true, fileType = "copy", data = "stockData/tiles/roofBlock.png"}
					},
					assets = {},
					settings = {
						isFile = true,
						fileType = "json",
						data = {
							name = "Default Horiz",
							type = "Tile",
							layer = 4,
							solid = false
						}
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