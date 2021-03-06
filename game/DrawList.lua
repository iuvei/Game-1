-- DrawList.lua

-- Purpose
----------------------------
-- manages draw order of objects submitted to it

-------------------------------------------------------------------------

-- global
DrawList = {}

------------------
-- Static Info
------------------
DrawList = Info:New
{
	objectType = "Controller",
	dataType = "Graphics",
	structureType = "Manager"
}


--------------
-- Object
--------------
function DrawList:New(data)

	local o = {}

	o.Info = Info:New
	{
		name = data.name or "...",
		objectType = "DrawList",
		dataType = "Graphics",
		structureType = "Object"
	}

	----------------
	-- Vars
	----------------

	o.mode = {}
	o.mode.options = {"Static", "Submit", "Sort"}
	o.mode.selected = "Submit"

	o.objects = {}
	o.objects.layerIndex = {}
	o.objects.lastLayerIndex = nil

	o.drawnThisFrame = 0

	o.layers = 
	{
		Skybox = {value = 1, active = false},
		Backdrop = {value = 2, active = false},
		Objects = {value = 3, active = true},
		Collision = {value = 4, active = true},
		Hud = {value = 5, active = true},
		HudOver = {value = 6, active = true},
		Overlap = {value = 7, active = true},
		DebugText = {value = 8, active = false},

		Scroll1 ={value = 9, active = true},
		Scroll2 ={value = 10, active = true},
		Scroll3 ={value = 11, active = true},
		Scroll4 ={value = 12, active = true},
		Scroll5 ={value = 13, active = true},
		Scroll6 ={value = 14, active = true},
		Scroll7 ={value = 15, active = true},
		Scroll8 ={value = 16, active = true},

		Scroll9 ={value = 17, active = true},
		Scroll10 ={value = 18, active = true},
		Scroll11 ={value = 19, active = true},
		Scroll12 ={value = 20, active = true},
		Scroll13 ={value = 21, active = true},
		Scroll14 ={value = 22, active = true},
		Scroll15 ={value = 23, active = true},
		Scroll16 ={value = 24, active = true},
		Scroll17 ={value = 25, active = true},
		Scroll18 ={value = 26, active = true},

		index = 
		{
			"Skybox", "Backdrop", "Objects", "Collision", "Hud", "HudOver", "Overlap", "DebugText",
			"Scroll1",
			"Scroll2",
			"Scroll3",
			"Scroll4",
			"Scroll5",
			"Scroll6",
			"Scroll7",
			"Scroll8",
			"Scroll9",
			"Scroll10",
			"Scroll11",
			"Scroll12",
			"Scroll13",
			"Scroll14",
			"Scroll15",
			"Scroll16",
			"Scroll17",
			"Scroll18",
		}
	}

	---------------------
	-- Static Functions
	---------------------

	function o:Update()
		self:UpdateMode()
	end 

	-- update functions for different modes
	-- currently only Submit is implemented
	function o:UpdateMode()
		if(self.mode.selected == "Submit") then
			self:Clear()
		end 
	end 

	-- get a layers value by name
	function o:GetLayer(name)
		return self.layers[name].value
	end 

	-- Create a layer in the DrawList
	function o:CreateLayer(layer)

		-- layer doesnt exist? --> create layer
		if(self.objects[layer] == nil) then
			self.objects[layer] = {}

			-- unordered list of all submitted objects, waiting to be sorted
			self.objects[layer].sort = {}

			-- finalized list in order
			self.objects[layer].draw = {}

			-- draws behind all other objects in this layer
			self.objects[layer].first = nil

			-- draws on top of all other objects in this layer
			self.objects[layer].last = nil

		end 

	end 

	-- add an object to be drawn at given layer
	-- data = Draw component
	function o:Submit(data)

		-- make layer if it doesn't exist
		self:CreateLayer(data.layer)

		-- stack object on top
		-- there is no sorting yet :| --> there is now
		self.objects[data.layer].sort[#self.objects[data.layer].sort + 1] = data

		-- store layers in use
		self.objects.layerIndex[#self.objects.layerIndex + 1] = data.layer

	end 

	-- sets the given object to draw first
	-- need to add a feature that lets you bump the first object with a new one
	-- data = Draw component --> not true its a local table
	function o:SubmitFirst(data)
		self:CreateLayer(data.layer)
		self.objects[data.layer].first = data
	end 
	 
	-- sets the given object to draw last
	-- data = Draw component --> not true its a local table
	function o:SubmitLast(data)
		self:CreateLayer(data.layer)
		self.objects[data.layer].last = data
	end 

	-- after the Update call, all objects have submitted here to be drawn
	-- now its time to sort them and stuff
	function o:PostUpdate()

		-- create list of used layers
		self:CompressAndSortLayerList()

		-- sort draw order of all objects submitted
		-- o.sort is just a pile of unsorted objects
		self:Sort()

	end 

	-- removes duplicate indexs of layers in use
	function o:CompressAndSortLayerList()

		local layerIndex = TableSort:UniqueVars(self.objects.layerIndex)
		TableSort:SortByString(layerIndex)

		self.objects.layerIndex = nil
		self.objects.layerIndex = layerIndex
	end 

	-- sorts all objects per layer by their depth value
	-- depth is calculated by each object and passed in
	-- so while sorting can always be done 
	-- it may not be sorted based on the same type of depth
	function o:Sort()

		local function tempCompare(a,b)
			return a.depth < b.depth
		end


		for i=1, #self.objects.layerIndex do

			local layerIndex = self.objects.layerIndex[i]

			table.sort(self.objects[layerIndex].sort, tempCompare)

			for j=1, #self.objects[layerIndex].sort do
				self.objects[layerIndex].draw[#self.objects[layerIndex].draw + 1] = self.objects[layerIndex].sort[j] 
			end 

		end 
				
	end 

	-- removes all objects
	-- used for per frame submit style draw list
	function o:Clear()

		local layerIndex = self.objects.layerIndex

		-- remove each depth
		for i=1, #layerIndex do

			-- remove each object
			
			for j=1, #self.objects[layerIndex[i]].draw do
				self.objects[layerIndex[i]].draw[j] = nil
			end 

			for j=1, #self.objects[layerIndex[i]].sort do
				self.objects[layerIndex[i]].sort[j] = nil
			end 

			self.objects[layerIndex[i]] = nil
		end 

		self.objects.lastLayerIndex = nil
		self.objects.lastLayerIndex = self.objects.layerIndex
		self.objects.layerIndex = nil
		self.objects.layerIndex = {}
	end

	-- draw all objects in order
	function o:Draw()

		-- draw all objects in all layers
		for i=1, #self.objects.layerIndex do

			repeat

				-- is this layer/depth active?
				if(self.layers[self.layers.index[self.objects.layerIndex[i]]].active == false) then
					break
				end

				local layerIndex = self.objects.layerIndex[i]

				-- first
				-- draw this object below all others
				if(self.objects[layerIndex].first) then
					self.objects[layerIndex].first.o.Draw:Draw()
					self.drawnThisFrame = self.drawnThisFrame + 1
				end 		

				-- draw each object in this layer
				for j=1, #self.objects[self.objects.layerIndex[i]].draw do


					if(self.objects[self.objects.layerIndex[i]].draw[j].isGroup) then

						-- flag for after drawing		
						local resetScissor = false
						local x = nil
						local y = nil
						local width = nil
						local height = nil
					
						-- set space to draw within --> good for panels
						if(self.objects[self.objects.layerIndex[i]].draw[j].scissorActive) then

							-- get scissor vars
							x = self.objects[self.objects.layerIndex[i]].draw[j].scissor.x - Camera.selectedCamera.Pos.x
							y = self.objects[self.objects.layerIndex[i]].draw[j].scissor.y - Camera.selectedCamera.Pos.y
							width = self.objects[self.objects.layerIndex[i]].draw[j].scissor.width
							height = self.objects[self.objects.layerIndex[i]].draw[j].scissor.height

							-- set draw rect
							love.graphics.setScissor(x, y, width, height)

							-- set flag
							resetScissor = true

						end 
						
						-- draw all objects in group
						for k=1, #self.objects[self.objects.layerIndex[i]].draw[j].drawables do

							-- is object excluded from this groups scissor?
							-- then disable scissor
							if(self.objects[self.objects.layerIndex[i]].draw[j].drawables[k].parent.noScissor) then
								love.graphics.setScissor()
							end 

							self.objects[self.objects.layerIndex[i]].draw[j].drawables[k]:Draw()
							self.drawnThisFrame = self.drawnThisFrame + 1

							-- re enable scissor if object was excluded
							if(resetScissor) then
								love.graphics.setScissor(x, y, width, height)
							end 

						end 

						-- disable scissor because group is done drawing
						if(resetScissor) then
							love.graphics.setScissor()
						end 

					else
						if(self.objects[self.objects.layerIndex[i]].draw[j].o.Draw) then	

							self.objects[self.objects.layerIndex[i]].draw[j].o.Draw:Draw()
							self.drawnThisFrame = self.drawnThisFrame + 1
						end
					end 


					

				end 

				-- last
				-- draw this object on top of all others
				if(self.objects[layerIndex].last) then
					self.objects[layerIndex].last.o.Draw:Draw()
					self.drawnThisFrame = self.drawnThisFrame + 1
				end 

			until true
		end

	end 


	-- info
	function o:PrintDebugText()

		local layerIndexString = ""

		for i=1, #self.objects.lastLayerIndex do
			if(i == 1) then
				layerIndexString = layerIndexString .. self.objects.lastLayerIndex[i]
			else
				layerIndexString = layerIndexString .. ", " .. self.objects.lastLayerIndex[i]
			end 
		end

		DebugText:TextTable
		{
			{text = "", obj = "DrawList" },
			{text = "Draw"},
			{text = "---------------------"},
			{text = "Layer Index: " .. layerIndexString},
			{text = "Drawn this Frame: " .. self.drawnThisFrame}
		}

		self.drawnThisFrame = 0
	end

	return o

end 


-------------
-- Setup
-------------
-- create the normal and static layer lists with DrawList.New

DrawList.objectList = DrawList:New{}
DrawList.staticObjectList = DrawList:New{}


----------------------
-- Static Functions
----------------------

function DrawList:GetLayer(name)
	return self.objectList:GetLayer(name)
end

function DrawList:GetLayerStatic(name)
	return self.staticObjectList:GetLayer(name)
end 

function DrawList:Submit(data)
	self.objectList:Submit(data)
end

function DrawList:SubmitStatic(data)
	self.staticObjectList:Submit(data)
end 

function DrawList:PostUpdate()
	self.objectList:PostUpdate()
	self.staticObjectList:PostUpdate()
end

function DrawList:Draw()
	self.objectList:Draw()	
end 

function DrawList:DrawStatic()
	self.staticObjectList:Draw()
end 

function DrawList:Update()
	self.objectList:Update()
	self.staticObjectList:Update()
end 



---------------
-- Static End
---------------

ObjectManager:AddStatic(DrawList)






-- Notes
-------------------- 
-- Keep in mind that the Pos values of the static list are not updated
-- so their Pos values act as if they are still 100 from the origin
-- need to have a conversion function I guess?

-- will most likely have to convert this into a static that can create an object
-- with all the implemented features
-- that way it can make a .layers and .staticLayers lists
-- that have the exact same functionality
-- it won't be fun, but thats what I should do

-- NEED
-- static layers that are not affected by the camera
-- but still are sorted just like other layers
-- most likely will be called as a seperate function
-- most features of self.layers can be mirrored over

-->DONE
-- needs to be part of a higherarchy called DrawManager or something
-- so that other stuff can factor in like Cameras and Shaders and stuff!

-- NEEDED
-- Layers as objects that have their own transform component
-- so that layers of objects can be moved, rotated, shader, etc independantly
-- right now layers are temporary and thats cool
-- but they could be so much more useful as objects
-- maybe they should not be layers but one level higher?

-- send objects and and layering value to draw them at during Update
-- when Draw calls back, sort the order of draws
-- then draw them all

-- objects with lower numbers are drawn first

-- try a couple different variations of draw order structure
-- I'd like to do an indexed version that uses no sorting

-- there should maybe be a way to make sure you cant submit an object more than once.... 
-- or should there? I dunno

-- need to hook this up to ObjectManager and get draw calls based on this and nothing else
-- actually I might just call this directly from the call back
-- no need to even go thru ObjectManager

-- what to do when an object is deleted?
-- how will it be removed from the list?

-- I want to do 2 variations of DrawList:

-- static DrawList
-- 	objects submit once and are drawn
-- 	nil objects are removed from drawList
-- 	makes it so a new list does not need to be reformed
-- 	but also makes updating sorting a bit weird

-- per frame DrawList
-- 	all objects submit to be drawn EVERY frame
-- 	draw all objects
-- 	then clear the draw list
-- 	this ensures that sorting is always up to date
-- 	but will probly take more processing -> perhaps not a big deal tho


-- WORKS - but is annoying to add a submit function to each object
-- not that big of a deal I guess
-- might create a draw component to handle stuff like that
-- but most draw funcitions are fairly different
-- so maybe I wont make a universal component for that

-- also I just realized that the index method I've created doesnt work
-- for 0 or negative values :|
-- maybe not the worst thing in the world but its def weird

-- NEEDED
-- "layering" seperate from "depth"
-- the current implementation is actually layering and does not sort by a
-- depth value
-- objects could submit their y or z value
-- that would actually work with what I already have but I want to have
-- a layering structure on top as well for different draw spaces and object types
-- hud, debug, text, sprites, skybox, etc

-- NEEDED
-- convert layer names to value interally instead of having to call GetLayer from the outside

-- DONE - sorta
-- toggleable layers and depths to draw or not draw
-- mostly for debug purposes

-- DONE
-- predefined layer values as names

-- DONE 
-- can call DrawList:SubmitFirst or SubmitLast
-- or create a Draw comoponent with Draw.first or Draw.last set to true
-- right now its passed thru Box to Draw on a New call, but needs to be modified to work differently for all objects
-- a LAST slot to draw a selected object on top of all others in its layer
-- also a FIRST for the opposite end, just cuz I might need it
-- last is way more important and useful tho



-- Old Code
----------------
