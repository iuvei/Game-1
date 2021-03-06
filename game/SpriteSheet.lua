-- SpriteSheet.lua

-- Purpose
--------------------------------------
-- load a single image
-- frames can be displayed from it
-- or the entire image
-- might need to change the name


--------------------------------------------------
local SpriteSheet = {}

-------------------
-- Static Info
-------------------

SpriteSheet.Info = Info:New
{
	objectType = "SpriteSheet",
	dataType = "Graphics",
	structureType = "Static"
}

-----------
-- Vars
-----------
SpriteSheet.loadPath = "graphics/"

-------------
-- Object
-------------

--{image, width, height, spriteWidth, spriteHeight}
function SpriteSheet:New(data)

	local fail = FailNew
	{
		table = data,
		members = {"image"}
	}

	if(fail) then
		return
	end 


	local o = {}

	--------------
	-- Info
	--------------

	o.Info = Info:New
	{
		name = data.name or "...",
		objectType = "SpriteSheet",
		dataType = "Graphics",
		structureType = "Object"
	}

	-----------
	-- Vars
	-----------

	-- image
	o.image = love.graphics.newImage(SpriteSheet.loadPath .. data.image)
	o.image:setFilter("nearest", "nearest")

	-- not sure this is actually needed anymore?
	-- reroute attempt to make refresh work --> its a weird idea I know but seems reasonable
	o.imageData = o.image:getData()

	--o.image = love.graphics.newImage(o.imageData)
	--o.image:setFilter("nearest", "nearest")

	-- vars
	o.width = o.image:getWidth()
	o.height = o.image:getHeight()

	o.spriteWidth = data.spriteWidth or 32
	o.spriteHeight = data.spriteHeight or 32

	o.filename = data.image


	------------------
	-- Functions
	------------------

	function o:Refresh()
		self.image:refresh()
	end 

	function o:Destroy()
		ObjectManager:Destroy(o.Info)
		self.image = nil
		self.imageData = nil
	end 

	----------
	-- End
	----------

	ObjectManager:Add{o}

	return o

end 


-- default if none if provided
SpriteSheet.noImage = SpriteSheet:New
{
	image = "NoImage.png"
}


---------------
-- Static End
---------------

ObjectManager:AddStatic(SpriteSheet)

return SpriteSheet




-- Notes
-------------------------------
-- Why no draw function?
	-- sprite sheets do not need to draw
	-- if you want to draw the whole sheet as a single image
	-- then create a sprite from it that is the entire size
	-- this way there is always a sprite sheet and a sprite
	-- that are seperate, so that the original image data is not changed

-- Image or ImageData?
	-- consider changing names of things to how love2D names them
	-- altho I'd really rather not :P