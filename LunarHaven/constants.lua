_CONSTANTS = {
	tileW = 32,
	tileH = 32,
	chunkW = 32,
	chunkH = 32,
	fizzix = {
		grav = 1.622,--9.807, -- gravity acceleration; but floaty.
		drag = 0.01,
		clamp = 0.0005
	},
	ui = {
		hotBarWidth = 1/8, -- this*screenwidth
		hotBarMargin = 1/20, -- this*screenheight
		hotBarTop = .3125, -- this*hotBarWidth
		hotBarGap = 1/16, -- this*hotBarWidth
		hotBarGutter = 1/8, -- this*hotBarWidth
		hotBarTabHeight = 1/4, -- this*(screenheight-hotBarMargin*screenheight*2)
		hotBarPadding = 1/20, -- this*hotBarWidth/2
	}
}

setmetatable(_G,{__index = _CONSTANTS})