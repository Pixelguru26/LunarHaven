local game = {}

game.colors = {{153,218,255,255},{153,218,255,255},{153,218,255,255},{0,128,128,255}}
game.state = 1

function game.lerp(a,b,c)
	return a+c*(b-a)
end

function game.update(dt)
	game.state = math.max((game.state+dt)%(#game.colors+1),1)
end
function game.draw()
	local c1,c2 = game.colors[math.floor(game.state)],game.colors[math.max((math.floor(game.state)+1)%(#game.colors+1),1)]
	local c = game.state%1
	local r,g,b,a = game.lerp(c1[1],c2[1],c),game.lerp(c1[2],c2[2],c),game.lerp(c1[3],c2[3],c),game.lerp(c1[4],c2[4],c)
	love.graphics.setColor(r,g,b,a)
	love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
	love.graphics.setColor(0,0,0,80)
	love.graphics.rectangle("fill",0,love.graphics.getHeight()/3,love.graphics.getWidth(),love.graphics.getHeight()/3)
	love.graphics.setColor(255,255,255,120)
	love.graphics.setFont(love.graphics.newFont(80))
	local x = love.graphics.getWidth()/2-love.graphics.getFont():getWidth("Broken!")/2
	local y = love.graphics.getHeight()/2-love.graphics.getFont():getHeight()/2
	love.graphics.print("Broken!",x,y)
	y = y+love.graphics.getFont():getHeight()
	love.graphics.setFont(love.graphics.newFont(20))
	local x = love.graphics.getWidth()/2-love.graphics.getFont():getWidth("...ooor just missing an actual gamestate to run.")/2
	love.graphics.print("...ooor just missing an actual gamestate to run.",x,y)
end

return game