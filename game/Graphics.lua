-- Graphics.lua
-- sets up window and other graphics stuff
-- this is just a temp file until 
-- I break the features down into other components

-- >:L BLEAH


local Color = require("Color")


local Graphics = {}



function Graphics:Setup()
		-- graphics setup

	love.window.setFullscreen(false, "desktop")
	love.graphics.setBackgroundColor(Color:AsTable(Color:Get("gray")))

end 



function Graphics:Update()
end 




return Graphics


