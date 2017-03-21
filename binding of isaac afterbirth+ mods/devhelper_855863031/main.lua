--[[ changes

]]

TearFlag = {
	FLAG_NO_EFFECT = 0,
	FLAG_SPECTRAL = 1,
	FLAG_PIERCING = 1<<1,
	FLAG_HOMING = 1<<2,
	FLAG_SLOWING = 1<<3,
	FLAG_POISONING = 1<<4,
	FLAG_FREEZING = 1<<5,
	FLAG_PARASITE = 1<<6,
	FLAG_COAL = 1<<7,
	FLAG_MAGIC_MIRROR = 1<<8,
	FLAG_POLYPHEMUS = 1<<9,
	FLAG_WIGGLE_WORM = 1<<10,
	FLAG_UNK1 = 1<<11, --No noticeable effect, but fruit cake can spawn those
	FLAG_IPECAC = 1<<12,
	FLAG_CHARMING = 1<<13,
	FLAG_CONFUSING = 1<<14,
	FLAG_ENEMIES_DROP_HEARTS = 1<<15,
	FLAG_TINY_PLANET = 1<<16,
	FLAG_ANTI_GRAVITY = 1<<17,
	FLAG_CRICKETS_BODY = 1<<18,
	FLAG_RUBBER_CEMENT = 1<<19,
	FLAG_FEAR = 1<<20,
	FLAG_PROPTOSIS = 1<<21,
	FLAG_FIRE = 1<<22,
	FLAG_STRANGE_ATTRACTOR = 1<<23,
	FLAG_PISCES = 1<<24,
	FLAG_PULSE_WORM = 1<<25,
	FLAG_RING_WORM = 1<<26,
	FLAG_FLAT_WORM = 1<<27,
	FLAG_SAD_BOMBS = 1<<28,
	FLAG_BUTT_BOMBS = 1<<29,
	FLAG_GLITTER_BOMBS = 1<<30,
	FLAG_HOOK_WORM = 1<<31,
	FLAG_GODHEAD = 1<<32,
	FLAG_GISH = 1<<33,
	FLAG_SCATTER_BOMBS = 1<<34,
	FLAG_EXPLOSIVO = 1<<35,
	FLAG_CONTINUUM = 1<<36,
	FLAG_HOLY_LIGHT = 1<<37,
	FLAG_BUMBO_TEARS = 1<<38,
	FLAG_SERPENTS_KISS = 1<<39,
	FLAG_TRACTOR_BEAM = 1<<40,
	FLAG_GODS_FLESH = 1<<41,
	FLAG_HEAD_OF_THE_KEEPER = 1<<42,
	FLAG_MYSTERIOUS_LIQUID = 1<<43,
	FLAG_OUROBOROS_WORM = 1<<44,
	FLAG_GLAUCOMA = 1<<45,
	FLAG_SINUS_INFECTION = 1<<46,
	FLAG_PARASITOID = 1<<47,
	FLAG_SULFURIC_ACID = 1<<48, 
	FLAG_COMPOUND_FRACTURE = 1<<49,
	FLAG_EYE_OF_BELIAL = 1<<50,
	FLAG_MIDAS = 1<<51,
	FLAG_EUTHANASIA = 1<<52,
	FLAG_JACOBS_LADDER = 1<<53,
	FLAG_LITTLE_HORN = 1<<54,
	FLAG_LUDOVICO_TECHNIQUE = 1<<55
}

RoomTransition = {
	TRANSITION_NONE = 0,
	TRANSITION_DEFAULT = 1,
	TRANSITION_STAGE = 2,
	TRANSITION_TELEPORT = 3,
	TRANSITION_4 = 4,
	TRANSITION_ANKH = 5,
	TRANSITION_DEAD_CAT = 6,
	TRANSITION_1UP = 7,
	TRANSITION_GUPPYS_COLLAR = 8,
	TRANSITION_JUDAS_SHADOW = 9,
	TRANSITION_LAZARUS_RAGS = 10,
	TRANSITION_11 = 11,
	TRANSITION_GLOWING_HOURGLASS = 12,
	TRANSITION_D7 = 13,
	TRANSITION_MISSING_POSTER = 14
}

-- Vector constants and quick Vector manipulation
-- Reduces memory usage by reusing Vectors
local VECTOR_ZERO = Vector(0,0)
local VECTOR_Q = Vector(0,0)
local function QVector(x,y)
	VECTOR_Q.X = x
	VECTOR_Q.Y = y
	return VECTOR_Q
end

local function UnpackVector(vector)
	return vector.X,vector.Y
end

local COLORS = 
{
	WHITE = Color(1,1,1,1,0,0,0),
	BLACK = Color(0,0,0,1,0,0,0)
}

function Now()
	return 0
end
-- Define the performance test only if os is defined
if os ~= nil then
	Now = os.time
	if require ~= nil then -- If require is defined, require socket
		local socket = require("socket")
		if socket ~= nil then -- If it loaded, use its gettime for a higher resolution timer
			Now = socket.gettime
		end
	end
	function PerformanceTest(iterations,callback)
		local t = Now()
		for i=1,iterations do
			callback()
		end
		return Now() - t
	end
	function Stopwatch()
		local stopwatch = {}
		local time = 0
		function stopwatch.Start(self)
			time = Now()
			return self
		end
		function stopwatch.Time()
			return Now() - time
		end
		return stopwatch
	end
end

local lastGarbage = 0
if collectgarbage ~= nil then
	function TrackGarbage()
		lastGarbage = collectgarbage("count")
	end
	function CheckGarbage()
		return collectgarbage("count") - lastGarbage
	end
end

-- Round a number to some amount of decimal places
local function Decimals(value,decimals)
	decimals = decimals or 2
	return math.floor(value * 10^decimals)/10^decimals
end

-- Get a Config::Item from an collectible ID
function GetConfigItemFromCollectible(id)
	local player = Isaac.GetPlayer(0)
	player:GetEffects():AddCollectibleEffect(id, false)
	local effect = player:GetEffects():GetCollectibleEffect(id)
	player:GetEffects():RemoveCollectibleEffect(id)
	return effect.Item
end

function GetConfigItemFromTrinket(id)
	local player = Isaac.GetPlayer(0)
	player:GetEffects():AddTrinketEffect(id, false)
	local effect = player:GetEffects():GetTrinketEffect(id)
	player:GetEffects():RemoveTrinketEffect(id)
	return effect.Item
end

function GetConfigItemFromNull(id)
	local player = Isaac.GetPlayer(0)
	player:GetEffects():AddNullEffect(id, false)
	local effect = player:GetEffects():GetNullEffect(id)
	player:GetEffects():RemoveNullEffect(id)
	return effect.Item
end

local DEV_RENDER_MODES = {
	NONE = 0,
	PLAYER = 1,
	ENTITIES = 2,
	EFFECTS = 3,
	TEARS = 4,
	LASERS = 5,
	ALL = 6,
	ENEMIES = 7,
	AMOUNT = 8
}

local devRender = DEV_RENDER_MODES.NONE
local forceStickyEntities = false -- If true, gives all entities the don't overwrite flag
local showPerformanceInfo = false -- If true, shows information about the current room
local stressTest = false -- If true, spawns a bunch of tears with random tear flags set to test lag
local godMode = false -- If true, ignores all damage dealt to the player
local drawEntityPositions = false -- If true, draws a cross at each entities position to help visualize offsets
local showEntityHealth = false -- If true, show an entities current health
local showEntityHealthBar = false -- If true, show an entities current health as a bar
local showDamageNumbers = false -- If true, show damage numbers when an entity takes damage
local renderFrames = 0 -- How many render frames have passed
local updateFrames = 0 -- How many update frames have passed
local keepEnemiesAlive = false -- If true, enemies that would have died will be healed to their full HP instead

local game = Game()
local player = nil
local level = nil
local room = nil
local roomEntities = nil
local collectibleIndex = 0

-- Pack varargs into a string including nils
local function PackString(...)
	local string = ""
	for n=1,select('#',...) do
	  local j = select(n,...)
		local text = "nil"
		if type(j) == "boolean" then
			if j then
			   text = "true"
			else
				text = "false"
			end
		else
			text = tostring(j) or "nil"
		end
		string = string .. text
	end
	return string
end

local LINE_LIMIT = 30 -- How many lines should be shown before removing old ones
local CONSOLE_POSITION = Vector(50,32) -- Where the console should be drawn
local CLEAR_CONSOLE = false -- If true, clears the console every frame
local skipLogging = false
local log = {}
-- The actual logging functionality
function Log(...)
	local string = PackString(...)
	if not skipLogging then
		table.insert(log,string)
		if #log > LINE_LIMIT then
			table.remove(log,1)
		end
	end
	return string
end

function DebugLog(...)
	Isaac.DebugString(Log(...))
end

function ClearLog()
	while #log > 0 do
		table.remove(log,1)
	end
end

function LogTable(table)
	local string = ""
	if table ~= nil then
		string = string .. Log("table",table,"#",#table) .. "\n"
		for i,j in pairs(table) do
			string = string .. Log(i,j) .."\n"
		end
	end
	return string
end

function LogMetaTable(table)
	if table then
		mt = getmetatable(table)
		return LogTable(mt)
	end
end

local logEntity = {}
function EntityLog(entity, ...)
	local key = entity.Index..":"..entity.Type
	if logEntity[key] == nil then
		logEntity[key] = {}
	end
	table.insert(logEntity[key],PackString(...))
end

function ClearEntityLog()
	for k in pairs(logEntity) do
		logEntity[k] = nil
	end
end

local logGridEntity = {}
local gridEntities = {}
local gridEntityRoomIndex = 0
local gridEntityStageIndex = 0
function GridEntityLog(index, ...)
	if logGridEntity[index] == nil then
		logGridEntity[index] = {}
	end
	table.insert(logEntity[index],PackString(...))
end

function ClearGridEntityLog()
	for k in pairs(logGridEntity) do
		logGridEntity[k] = nil
	end
end

local FONT_FRAMES = {
	["0"] 	= 0		,
	["1"] 	= 1		,
	["2"] 	= 2		,
	["3"] 	= 3		,
	["4"] 	= 4		,
	["5"] 	= 5		,
	["6"] 	= 6		,
	["7"] 	= 7		,
	["8"] 	= 8		,
	["9"] 	= 9		,
	[" "]	= 10	,
	["."]	= 11	,
	["+"]	= 12	,
	["-"]	= 13	,
	["e"]	= 14	,
	[""]	= 15	,
	[""]	= 16	,
	[""]	= 17	,
	[""]	= 18	,
	[""]	= 19	,
	[""]	= 20	,
	[""]	= 21	,
	[""]	= 22	,
	[""]	= 23	,
	[""]	= 24	,
	[""]	= 25	,
	["a"] 	= 26	,	["A"] 	= 26	,
	["b"] 	= 27	,	["B"] 	= 27	,
	["c"] 	= 28	,	["C"] 	= 28	,
	["d"] 	= 29	,	["D"] 	= 29	,
	["e"] 	= 30	,	["E"] 	= 30	,
	["f"] 	= 31	,	["F"] 	= 31	,
	["g"] 	= 32	,	["G"] 	= 32	,
	["h"] 	= 33	,	["H"] 	= 33	,
	["i"] 	= 34	,	["I"] 	= 34	,
	["j"] 	= 35	,	["J"] 	= 35	,
	["k"]	= 36	,	["K"]	= 36	,
	["l"]	= 37	,	["L"]	= 37	,
	["m"]	= 38	,	["M"]	= 38	,
	["n"]	= 39	,	["N"]	= 39	,
	["o"]	= 40	,	["O"]	= 40	,
	["p"]	= 41	,	["P"]	= 41	,
	["q"]	= 42	,	["Q"]	= 42	,
	["r"]	= 43	,	["R"]	= 43	,
	["s"]	= 44	,	["S"]	= 44	,
	["t"]	= 45	,	["T"]	= 45	,
	["u"]	= 46	,	["U"]	= 46	,
	["v"]	= 47	,	["V"]	= 47	,
	["w"]	= 48	,	["W"]	= 48	,
	["x"]	= 49	,	["X"]	= 49	,
	["y"]	= 50	,	["Y"]	= 50	,
	["z"]	= 51	,	["Z"]	= 51	,
	["/"] 	= 52	,
	["\\"] 	= 53	,
	["_"] 	= 54	,
	["!"] 	= 55	,
	["@"] 	= 56	,
	["#"] 	= 57	,
	["%"] 	= 58	,
	["^"] 	= 59	,
	["*"] 	= 60	,
	["("] 	= 61	,
	[")"]	= 62	,
	["["]	= 63	,
	["]"]	= 64	,
	["{"]	= 65	,
	["}"]	= 66	,
	["|"]	= 67	,
	["?"]	= 68	,
	["$"]	= 69	,
	[","]	= 70	,
	["'"]	= 71	,
	["\""]	= 72	,
	["="]	= 73	,
	[":"]	= 74	,
	[""]	= 75	,
	[""]	= 76	,
	[""]	= 77	
}

local FONT_COLORS = 
{
	["\x00"] = Color(1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0),	-- White
	["\x01"] = Color(0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0),	-- Black
	["\x02"] = Color(1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0),	-- Red
	["\x03"] = Color(0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0),	-- Green
	["\x04"] = Color(0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0),	-- Blue
	["\x05"] = Color(1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0),	-- Magenta
	["\x06"] = Color(0.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0),	-- Cyan
	["\x07"] = Color(1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0),	-- Yellow
	["\x08"] = Color(0.5, 0.5, 0.5, 1.0, 0.0, 0.0, 0.0),	-- Grey
	["\x09"] = Color(1.0, 0.5, 0.5, 1.0, 0.0, 0.0, 0.0),	-- Light Red
	["\x0A"] = Color(0.5, 1.0, 0.5, 1.0, 0.0, 0.0, 0.0),	-- Light Green
	["\x0B"] = Color(0.5, 0.5, 1.0, 1.0, 0.0, 0.0, 0.0),	-- Light Blue
	["\x0C"] = Color(1.0, 0.5, 1.0, 1.0, 0.0, 0.0, 0.0),	-- Light Magenta
	["\x0D"] = Color(0.5, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0),	-- Pale Cyan
	["\x0E"] = Color(1.0, 1.0, 0.5, 1.0, 0.0, 0.0, 0.0),	-- Pale Yellow
	["\x0F"] = Color(1.0, 0.5, 0.0, 1.0, 0.0, 0.0, 0.0) 	-- Orange
}

local FONT_WIDTH  = 6
local FONT_HEIGHT = 7
local font = Sprite()
font:Load("/gfx/dev_font.anm2",true)
font:Play("Idle")
local CHARACTER_LIMIT = 1000
local customTextTranslationVector = Vector(0,0)
local newline = "\n"
local function RenderCustomText(x,y,color,args)
	if args ~= nil and #args > 0 then
		font.Color = color
		customTextTranslationVector.X = x
		customTextTranslationVector.Y = y
		local frame = -1
		for i,string in ipairs(args) do
			string = tostring(string)
			--for j=1,math.min(#string,CHARACTER_LIMIT),1 do
			--	local char = string:sub(j,j)
			for char in string:gmatch(".") do
				if char == newline then
					customTextTranslationVector.X = x
					customTextTranslationVector.Y = customTextTranslationVector.Y + FONT_HEIGHT
				elseif FONT_COLORS[char] ~= nil then
					font.Color = FONT_COLORS[char]
				else
					frame = FONT_FRAMES[char] or -1
					if frame ~= -1 then
						font:SetLayerFrame(0,frame)
						font:Render(customTextTranslationVector,VECTOR_ZERO,VECTOR_ZERO)
					end
					customTextTranslationVector.X = customTextTranslationVector.X + FONT_WIDTH
				end
				char = nil
			end
			customTextTranslationVector.X = x
			customTextTranslationVector.Y = customTextTranslationVector.Y + FONT_HEIGHT
		end
	end
end

function CompareEntity(a,b) -- Checks to make sure the Entity being referenced is the right Entity
	-- If the type, variant, subtype and index are all the same, it SHOULD be the Entity we're looking for
	return a ~= nil and b ~= nil and a.Type == b.Type and a.Variant == b.Variant and a.SubType == b.SubType and a.Index == b.Index
end

function FindEntity(entityLike,entityList)
	local entities = entityList or Isaac.GetRoomEntities()
	for i,entity in ipairs(entities) do -- For every entity in the room
		if CompareEntity(entityLike,entity) then -- If a comparison between the entityLike and our entity is true
			return entity -- Return thr entity we found
		end
	end
end

function HasParent(entity,parent) -- Loops through all Parent to check if an Entity is an ancestor to another Entity
	-- Make sure the entity is not its own parent
	while entity ~= nil and not CompareEntity(entity,parent) and not CompareEntity(entity,entity.Parent) do
		-- If the Entity has a Parent and it's the Parent we're looking for
		if entity.Parent ~= nil and CompareEntity(entity.Parent,parent) then
			return true
		end
		-- We didn't find the Parent, so check the Parent's Parent
		entity = entity.Parent
	end
	-- We never found the parent, so the Entity we're checking is not an ancestor
	return false
end

function LastChild(entity)
	while entity ~= nil and entity.Child ~= nil do
		entity = entity.Child
	end
	return entity
end

function DoWithAllChildren(entity, callback)
	while entity ~= nil do
		callback(entity)
		entity = entity.Child
	end
end

-- Hue Saturation Value to Red Green Blue
function HSVRGB(h,s,v)
	h = h %360
	local c = v * s
	local x = c * (1- math.abs((h/60) % 2 -1 ))
	local m = v-c
	local rr = 0
	local gg = 0
	local bb = 0
	if h < 60 then
		rr = c
		gg = x
	elseif h < 120 then
		rr = x
		gg = c
	elseif h < 180 then
		gg = c
		bb = x
	elseif h < 240 then
		gg = x
		bb = c
	elseif h < 300 then
		rr = x
		bb = c
	elseif h < 360 then
		rr = c
		bb = x
	end
	local r = (rr+m)*255
	local g = (gg+m)*255
	local b = (bb+m)*255
	return math.floor(r),math.floor(g),math.floor(b)
end

function ChangeSprite(entity,path,animation)
	if entity:GetSprite():IsLoaded() and entity:GetSprite():GetFilename() ~= path then
		entity:GetSprite():Load(path,true)
		entity:GetSprite():Play(animation)
	end
end

function RenderText(x,y,args)
	for i,j in pairs(args) do
		Isaac.RenderText(tostring(j),x,y+i*LINE_HEIGHT,255,255,255,255)
	end
end

function RenderColoredText(x,y,color,args)
	for i,j in pairs(args) do
		Isaac.RenderText(tostring(j),x,y+i*LINE_HEIGHT,color.R,color.G,color.B,color.A)
	end
end

local mod = RegisterMod("devhelper",1)

local function ClearCollectibleCostumes()
	local player = Isaac.GetPlayer(0)
	for i=1,1000,1 do
		player:TryRemoveCollectibleCostume(i,false)
	end
end

local function ChangeDevRenderMode(to)
	devRender = to
	if devRender >= DEV_RENDER_MODES.AMOUNT then
		devRender = 0
	elseif devRender < 0 then
		devRender = DEV_RENDER_MODES.AMOUNT - 1
	end
	Log("Render mode changed to ",
		(devRender == DEV_RENDER_MODES.NONE and "none") or 
		(devRender == DEV_RENDER_MODES.PLAYER and "player") or 
		(devRender == DEV_RENDER_MODES.ENTITIES and "entities") or 
		(devRender == DEV_RENDER_MODES.EFFECTS and "effects") or 
		(devRender == DEV_RENDER_MODES.TEARS and "tears") or 
		(devRender == DEV_RENDER_MODES.LASERS and "lasers") or 
		(devRender == DEV_RENDER_MODES.ENEMIES and "enemies") or 
		(devRender == DEV_RENDER_MODES.ALL and "all")
	)
end

local UI_SPRITE = Sprite()
UI_SPRITE:Load("gfx/dev_ui.anm2", true)

local renderPoints = {}
function RenderPoint(x,y,scaleX,scaleY,color)
	table.insert(renderPoints,{x,y,scaleX or 1, scaleY or 1,color or COLORS.WHITE})
end

function RenderWorldPoint(x,y,scaleX,scaleY,color)
	local position = Isaac.WorldToRenderPosition(QVector(x,y)) + game:GetRoom():GetRenderScrollOffset()
	table.insert(renderPoints,{position.X,position.Y,scaleX or 1, scaleY or 1,color or COLORS.WHITE})
end

local renderLines = {}
local LINE_WIDTH = 1
function RenderLine(x1,y1,x2,y2,width,color)
	local vector = QVector(x2-x1,y2-y1)
	table.insert(renderLines,{x1,y1,vector:GetAngleDegrees(),vector:Length(),width or 1,color or COLORS.WHITE})
end

function RenderWorldLine(x1,y1,x2,y2,width,color)
	local position = Isaac.WorldToRenderPosition(QVector(x1,y1)) + game:GetRoom():GetRenderScrollOffset()
	local vector = QVector(x2-x1,y2-y1)
	table.insert(renderLines,{position.X,position.Y,vector:GetAngleDegrees(),vector:Length(),width or 1,color or COLORS.WHITE})
end

function RenderVector(x,y,vector,width,color)
	table.insert(renderLines,{x,y,vector:GetAngleDegrees(),vector:Length(),width or 1,color or COLORS.WHITE})
end

function RenderWorldVector(x,y,vector,width,color)
	local position = Isaac.WorldToRenderPosition(QVector(x,y)) + game:GetRoom():GetRenderScrollOffset()
	table.insert(renderLines,{position.X, position.Y, vector:GetAngleDegrees(), vector:Length(), width or 1, color or COLORS.WHITE})
end

function LogPropget(userdata)
	local mt = getmetatable(userdata)
	for k,v in pairs(mt.__propget) do
		--Log(k,v)
		Log(k,userdata[k])
	end
end

function LogPropset(userdata)
	local mt = getmetatable(userdata)
	for k,v in pairs(mt.__propset) do
		--Log(k,v)
		Log(k,userdata[k])
	end
end

function mod:PostRender()
	renderFrames = renderFrames + 1
	
	if Input.IsButtonTriggered(Keyboard.KEY_PAGE_UP, 0) then
		ChangeDevRenderMode(devRender+1)
	end
	
	if Input.IsButtonTriggered(Keyboard.KEY_PAGE_DOWN, 0) then
		ChangeDevRenderMode(devRender-1)
	end

	if Input.IsButtonPressed(Keyboard.KEY_LEFT_CONTROL, 0) or Input.IsButtonPressed(Keyboard.KEY_RIGHT_CONTROL, 0) then
		if Input.IsButtonTriggered(Keyboard.KEY_1, 0) then
			godMode = not godMode
			local player = Isaac.GetPlayer(0)
			if godMode then
				player:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
				player:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			else
				player:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
				player:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
			end
			Log("God mode ",godMode and "enabled" or "disabled")
		end

		if Input.IsButtonTriggered(Keyboard.KEY_3, 0) then
			forceStickyEntities = not forceStickyEntities
			Log("Force don't overwrite entity flag ",forceStickyEntities and "enabled" or "disabled")
		end

		if Input.IsButtonTriggered(Keyboard.KEY_4, 0) then
			showPerformanceInfo = not showPerformanceInfo
			Log("Performance info ",showPerformanceInfo and "enabled" or "disabled")
		end

		if Input.IsButtonTriggered(Keyboard.KEY_5, 0) then
			Isaac.GetPlayer(0):ClearCostumes()
		end

		if Input.IsButtonTriggered(Keyboard.KEY_6, 0) then
			drawEntityPositions = not drawEntityPositions
			Log("Show entity positions ",drawEntityPositions and "enabled" or "disabled")
		end

		if Input.IsButtonTriggered(Keyboard.KEY_7, 0) then
			if skipLogging then
				skipLogging = false
				Log("Skip logging disabled")
			else
				Log("Skip logging enabled")
				skipLogging = true
			end
		end

		if Input.IsButtonTriggered(Keyboard.KEY_8, 0) then
			showEntityHealth = not showEntityHealth
			Log("Entity health ",showEntityHealth and "enabled" or "disabled")
		end

		if Input.IsButtonTriggered(Keyboard.KEY_T, 0) then
			stressTest = not stressTest
			Log("Stress test ",stressTest and "enabled" or "disabled")
		end

		if Input.IsButtonTriggered(Keyboard.KEY_E, 0) then
			keepEnemiesAlive = not keepEnemiesAlive
			Log("Healthy enemies ",keepEnemiesAlive and "enabled" or "disabled")
		end
		if Input.IsButtonTriggered(Keyboard.KEY_C, 0) then
			for i = 0,10,1 do
				if collectibleIndex >= 1 and collectibleIndex < 511 then
					player:AddCollectible(collectibleIndex,0,true)
				end
				collectibleIndex = collectibleIndex + 1
			end
		end
		if Input.IsButtonTriggered(Keyboard.KEY_H, 0) then
			Isaac.DebugString(DumpTable(Isaac.GetPlayer(0):GetMultiShotParams()))
			Isaac.DebugString(DumpTable(getmetatable(Isaac.GetPlayer(0):GetMultiShotParams())))
		end
	end

	if #renderPoints > 0 then
		UI_SPRITE:Play("Point")
		for i,point in ipairs(renderPoints) do
			UI_SPRITE.Offset = QVector(point[1],point[2])
			UI_SPRITE.Scale = QVector(point[3],point[4])
			UI_SPRITE.Rotation = 0
			UI_SPRITE.Color = point[5]
			UI_SPRITE:Render(VECTOR_ZERO,VECTOR_ZERO,VECTOR_ZERO)
		end
	end
	if #renderLines > 0 then
		UI_SPRITE:Play("Line")
		for i,line in ipairs(renderLines) do
			UI_SPRITE.Offset = VECTOR_ZERO
			UI_SPRITE.Scale = QVector(line[4]/LINE_WIDTH,line[5])
			UI_SPRITE.Rotation = line[3]
			UI_SPRITE.Color = line[6]
			UI_SPRITE:Render( QVector(line[1],line[2]),VECTOR_ZERO,VECTOR_ZERO)
		end
	end
	if roomEntities ~= nil and #roomEntities > 0 then
		local scrollOffset = nil
		for i,entity in pairs(roomEntities) do
			local key = entity.Index..":"..entity.Type
			if logEntity[key] ~= nil then
				if scrollOffset == nil then
					scrollOffset = game:GetLevel():GetCurrentRoom():GetRenderScrollOffset()
				end
				local x,y = UnpackVector(Isaac.WorldToRenderPosition(entity.Position) + scrollOffset)
				RenderCustomText(x,y,COLORS.WHITE,logEntity[key])
			end
		end
	end

	RenderCustomText(CONSOLE_POSITION.X, CONSOLE_POSITION.Y,COLORS.WHITE,log)
end
mod:AddCallback( ModCallbacks.MC_POST_RENDER, mod.PostRender)

function mod:PostUpdate()
	level = game:GetLevel()
	room = level:GetCurrentRoom()
	updateFrames = updateFrames + 1
	player = Isaac.GetPlayer(0)
	if stressTest then
		for i=1,25,1 do
			--[[local tear = player:FireTear(room:GetRandomPosition(0),VECTOR_ZERO,false,false,false)
			tear.TearFlags = math.random( 0, 0xFFFFFFFF )
			tear:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)]]
			Isaac.Spawn(1000,5,0,room:GetRandomPosition(0),VECTOR_ZERO,nil)
		end
	end

	roomEntities = Isaac.GetRoomEntities()
	if Input.IsButtonPressed(Keyboard.KEY_DELETE, 0) then
		ClearLog()
	end
	if Input.IsButtonPressed(Keyboard.KEY_LEFT_CONTROL, 0) or Input.IsButtonPressed(Keyboard.KEY_RIGHT_CONTROL, 0) then
		if Input.IsButtonPressed(Keyboard.KEY_2, 0) then
			Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS,true,false,true,false)
		end
		if Input.IsButtonPressed(Keyboard.KEY_9, 0) then
			for i=1,10,1 do
				Isaac.Spawn(13,0,0,player.Position,Vector(0,0),player)
			end
		end
	end
	if roomEntities ~= nil then
		for i,entity in pairs(roomEntities) do
			local entityPosition = entity.Position

			if drawEntityPositions then
				entityPosition = entityPosition or entity.Position
				RenderWorldPoint(entityPosition.X,entityPosition.Y,3,3,COLORS.BLACK)
				RenderWorldPoint(entityPosition.X,entityPosition.Y)
			end
			if forceStickyEntities then
				entity:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
			end
			local renderText = false
			if devRender == DEV_RENDER_MODES.PLAYER then
				if entity.Type == EntityType.ENTITY_PLAYER  then
					renderText = true
				end
			elseif devRender == DEV_RENDER_MODES.ENTITIES then
				if entity.Type ~= EntityType.ENTITY_EFFECT and entity.Type ~= EntityType.ENTITY_PLAYER then
					renderText = true
				end
			elseif devRender == DEV_RENDER_MODES.EFFECTS then
				if entity.Type == EntityType.ENTITY_EFFECT  then
					renderText = true
				end
			elseif devRender == DEV_RENDER_MODES.TEARS  then
				if entity.Type == EntityType.ENTITY_TEAR  then
					renderText = true
				end
			elseif devRender == DEV_RENDER_MODES.LASERS  then
				if entity.Type == EntityType.ENTITY_LASER  then
					renderText = true
				end
			elseif devRender == DEV_RENDER_MODES.ENEMIES  then
				if entity:IsEnemy() then
					renderText = true
				end
			elseif devRender == DEV_RENDER_MODES.ALL then
				renderText = true
			end
			if entity:IsActiveEnemy() then
				if showEntityHealth then
					EntityLog(entity,"\x09",tostring(Decimals(entity.HitPoints)))
				end
			end
			if renderText then
				entityPosition = entityPosition or entity.Position
				EntityLog(entity,
					entity:IsActiveEnemy() and "\x09" or "",
					entity.Index,":",entity.Type,".",entity.Variant,".",entity.SubType,
					" @ ",math.floor(entityPosition.X),",",math.floor(entityPosition.Y)," ",entity:GetEntityFlags())
				EntityLog(entity,"Depth/Z ",entity.DepthOffset,"/",entity.RenderZOffset)
				EntityLog(entity,"Mass ",entity.Mass)
				if entity.Parent ~= nil then
					EntityLog(entity,"Parent ",entity.Parent.Index)
				end

				if entity.Child ~= nil then
					EntityLog(entity,"Child ",entity.Child.Index)
				end
				if entity.Type == EntityType.ENTITY_PICKUP then
					EntityLog(entity,"Timeout ",entity:ToPickup().Timeout)
					EntityLog(entity,"State ",entity:ToPickup().State)
				end
				if entity.Type == EntityType.ENTITY_TEAR then
					EntityLog(entity,"TearFlags ",entity:ToTear().TearFlags)
				end
				if entity.Type == EntityType.ENTITY_LASER then
					EntityLog(entity,"TearFlags ",entity:ToLaser().CollisionDamage)
				end
				if entity.Type == EntityType.ENTITY_TEAR or entity.Type == EntityType.ENTITY_LASER then
					EntityLog(entity,"CollisionDamage ",entity.CollisionDamage)
				end
				if entity:IsEnemy() then
					local npc = entity:ToNPC()
					if npc ~= nil then
						EntityLog(entity,"Projectile Cooldown/Delay ",npc.ProjectileCooldown,"/",npc.ProjectileDelay)
						EntityLog(entity,"State/State Frame ",npc.State,"/",npc.StateFrame)
						EntityLog(entity,"I1/I2 ",npc.I1,"/",npc.I2)
					end
				end
			end
			if entityPosition.X < -5000 or entityPosition.X > 5000 or entityPosition.Y < -5000 or entityPosition.Y > 5000 then
				entity:Remove()
			end
		end
	end
	if showPerformanceInfo and player ~= nil then
		EntityLog(player,"R",level:GetCurrentRoomIndex()," ",room:GetGridWidth(),"x",room:GetGridHeight(),"\n",
		#roomEntities,"room entities\n",
		updateFrames,"/",renderFrames," U/R Frames\n",
		collectgarbage ~= nil and collectgarbage("count")
		)
	end
end
mod:AddCallback( ModCallbacks.MC_POST_UPDATE, mod.PostUpdate)

function mod:EntityTakeDamage(entity, amount, flag, source, countdownFrames)
	if entity.Type == EntityType.ENTITY_PLAYER and godMode then
		return false
	elseif entity:IsVulnerableEnemy() and keepEnemiesAlive then
		entity.HitPoints = entity.HitPoints + amount
	end
end
mod:AddCallback( ModCallbacks.MC_ENTITY_TAKE_DMG, mod.EntityTakeDamage )

function mod:PostPlayerEffectUpdate()
	if CLEAR_CONSOLE then
		ClearLog()
	end
	ClearEntityLog()
	while #renderPoints > 0 do
		table.remove(renderPoints,1)
	end
	while #renderLines > 0 do
		table.remove(renderLines,1)
	end
end
mod:AddCallback( ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.PostPlayerEffectUpdate)

--[[
   Author: Julio Manuel Fernandez-Diaz
   Date:   January 12, 2007
   (For Lua 5.1)
   
   Modified slightly by RiciLake to avoid the unnecessary table traversal in tablecount()

   Formats tables with cycles recursively to any depth.
   The output is returned as a string.
   References to other tables are shown as values.
   Self references are indicated.

   The string returned is "Lua code", which can be procesed
   (in the case in which indent is composed by spaces or "--").
   Userdata and function keys and values are shown as strings,
   which logically are exactly not equivalent to the original code.

   This routine can serve for pretty formating tables with
   proper indentations, apart from printing them:

	  print(table.show(t, "t"))   -- a typical use
   
   Heavily based on "Saving tables with cycles", PIL2, p. 113.

   Arguments:
	  t is the table.
	  name is the name of the table (optional)
	  indent is a first indentation (optional).
--]]
function DumpTable(t, name, indent)
   local cart     -- a container
   local autoref  -- for self references

   --[[ counts the number of elements in a table
   local function tablecount(t)
	  local n = 0
	  for _, _ in pairs(t) do n = n+1 end
	  return n
   end
   ]]
   -- (RiciLake) returns true if the table is empty
   local function isemptytable(t) return next(t) == nil end

   local function basicSerialize (o)
	  local so = tostring(o)
	  if type(o) == "function" and debug ~= nil then
		 local info = debug.getinfo(o, "S")
		 -- info.name is nil because o is not a calling level
		 if info.what == "C" then
			return string.format("%q", so .. ", C function")
		 else 
			-- the information is defined through lines
			return string.format("%q", so .. ", defined in (" ..
				info.linedefined .. "-" .. info.lastlinedefined ..
				")" .. info.source)
		 end
	  elseif type(o) == "number" or type(o) == "boolean" then
		 return so
	  else
		 return string.format("%q", so)
	  end
   end

   local function addtocart (value, name, indent, saved, field)
	  indent = indent or ""
	  saved = saved or {}
	  field = field or name

	  cart = cart .. indent .. field

	  if type(value) ~= "table" then
		 cart = cart .. " = " .. basicSerialize(value) .. ";\n"
	  else
		 if saved[value] then
			cart = cart .. " = {}; -- " .. saved[value] 
						.. " (self reference)\n"
			autoref = autoref ..  name .. " = " .. saved[value] .. ";\n"
		 else
			saved[value] = name
			--if tablecount(value) == 0 then
			if isemptytable(value) then
			   cart = cart .. " = {};\n"
			else
			   cart = cart .. " = {\n"
			   for k, v in pairs(value) do
				  k = basicSerialize(k)
				  local fname = string.format("%s[%s]", name, k)
				  field = string.format("[%s]", k)
				  -- three spaces between levels
				  addtocart(v, fname, indent .. "   ", saved, field)
			   end
			   cart = cart .. indent .. "};\n"
			end
		 end
	  end
   end

   name = name or "__unnamed__"
   if type(t) ~= "table" then
	  return name .. " = " .. basicSerialize(t)
   end
   cart, autoref = "", ""
   addtocart(t, name, indent)
   return cart .. autoref
end
