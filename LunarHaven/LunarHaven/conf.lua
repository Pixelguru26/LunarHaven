function love.conf(t)
	t.window.width = 800
	t.window.height = 600
	t.window.resizable = true

	t.title = "Lunar Haven Test Mess"
	t.console = true
	t.identity = "Lunar_Haven"
    t.version = "0.9.2"

    t.modules.physics = false
    t.modules.joystick = false
    t.modules.touch = false
    t.modules.video = false
end