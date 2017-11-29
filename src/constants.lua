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
		-- hotbar constants - Pixel
		-- hotBarWidth = 1/8, -- this*screenwidth
		-- hotBarMargin = 1/20, -- this*screenheight
		-- hotBarTop = .3125, -- this*hotBarWidth
		-- hotBarGap = 1/16, -- this*hotBarWidth
		-- hotBarGutter = 1/8, -- this*hotBarWidth
		-- hotBarTabHeight = 1/4, -- this*(screenheight-hotBarMargin*screenheight*2)
		-- hotBarPadding = 1/20, -- this*hotBarWidth/2

		spriteScale = 2, -- general sprite section scaling for this mess

		-- hotbar constants - Georjo
		hotBarWidth = 1/8, -- this*screenwidth
		hotBarHeight = 17/20, -- this*screenheight

		-- pixel editor constants - Georjo
		editorPaddingLeft = 16, -- this*scale
		editorPaddingRight = 64, -- w = screenwidth - this*scale - hotBarWidth*screenWidth
		editorPaddingTop = 16, -- this*scale
		editorPaddingBottom = 16, -- h = screenheight - this*scale
		editorFramesNameRatio = 4/5, -- ratio of frame selector width to UI bottom width
		editorFrameSizeRatio = 1/10 -- w = this*frameboxwidth
	},
	modsDir = love.filesystem.getSourceBaseDirectory().."/mods"
}

setmetatable(_G,{__index = _CONSTANTS})