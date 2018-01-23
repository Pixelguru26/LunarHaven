local UI = {}

function UI.load()
	local element,frame = require("libs/ui")()
	UI.frame = frame.new{dims = Rec(0,0,400,400),resDep = true}
	UI.frame.elements[1] = element.new{dims = Rec(0,0,1/2,1/2)}
end

function UI.draw()
	UI.frame:draw()
end

return UI