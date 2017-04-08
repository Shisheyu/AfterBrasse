--bug bit avec miracle???? doubtful ne s'enlève pas et wealth fait spawn des piedestaux en plus

local NUM_BLESSINGS = 6 --6
local currentBlessing = nil

local collectibleHasSpawned = false
local wealth_pickup_spawned = false
local blessing_miracle_heal = false

function _Stillbirth:useBlessing(curse)
	local player = Isaac.GetPlayer(0)
	if curse == LevelCurse.CURSE_NONE and not player:HasCollectible(Items.white_candle_i) then
		currentBlessing = ""
		return curse
	else
		local rand = math.random(g_vars.BLESSING_CHANCE*NUM_BLESSINGS) --1/3 d'avoir une blessing
		if rand == 1 then
			currentBlessing = "guide"
			return bit.bor(Curses.blessing_guide, curse)
		elseif rand == 2 then
			currentBlessing = "light"
			return bit.bor(Curses.blessing_light, curse)
		elseif rand == 3 then
			currentBlessing = "miracle"
			return bit.bor(Curses.blessing_miracle, curse)
		elseif rand == 4 then
			currentBlessing = "mighty"
			return bit.bor(Curses.blessing_acceptance, curse)
		elseif rand == 5 then
			currentBlessing = "wealth"
			return bit.bor(Curses.blessing_wealth, curse)
		elseif rand == 6 then
			currentBlessing = "doubtful"
			return bit.bor(Curses.blessing_doubtful, curse)
		else
			currentBlessing = nil
			return curse
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, _Stillbirth.useBlessing)

function _Stillbirth:blessingLight()
	if (bit.band(Game():GetLevel():GetCurses(), Curses.blessing_light) ~= Curses.blessing_light) then return end
	Game():GetLevel():ApplyMapEffect()
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.blessingLight)

function _Stillbirth:blessingGuide()
	if (bit.band(Game():GetLevel():GetCurses(), Curses.blessing_guide) ~= Curses.blessing_guide) then return end
	Game():GetLevel():ApplyCompassEffect()
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.blessingGuide)

function _Stillbirth:blessingMiracle()
	if (bit.band(Game():GetLevel():GetCurses(), Curses.blessing_miracle) ~= Curses.blessing_miracle) then return end
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	if room:GetFrameCount() == 1 then blessing_miracle_heal = false end
	if isRoomOver(room) and room:IsFirstVisit() and not blessing_miracle_heal then
		local rand = math.random(10) --1/10 de heal 1/2 coeur rouge
		blessing_miracle_heal = true
		if rand == 1 then
			player:AddHearts(1)
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.blessingMiracle)

function _Stillbirth:blessingAcceptance()
	local player = Isaac.GetPlayer(0)
	if (bit.band(Game():GetLevel():GetCurses(), Curses.blessing_acceptance) ~= Curses.blessing_acceptance) or player:HasCollectible(CollectibleType.COLLECTIBLE_CHAMPION_BELT) or player:HasTrinket(TrinketType.TRINKET_PURPLE_HEART) then return end
    local entities = Isaac.GetRoomEntities()
    local room = Game():GetRoom()
    if room:GetFrameCount() == 1 then
    	for i=1, #entities do
    		local e = entities[i]
    		if e:IsVulnerableEnemy() then
    			if e:ToNPC():IsChampion() and not e:IsBoss() then
    				--Game():RerollEnnemy(e:ToNPC())
    				e:Remove()
    			end
    		end
    	end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.blessingAcceptance)

function _Stillbirth:blessingWealth()
	if (bit.band(Game():GetLevel():GetCurses(), Curses.blessing_wealth) ~= Curses.blessing_wealth) then return end
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()
	local room = Game():GetRoom()
	if room:GetFrameCount() == 1 then
		wealth_pickup_spawned = false
	end
	for i=1, #entities do
		local e = entities[i]
		if e.Type == 5 and not wealth_pickup_spawned and isRoomOver(room) and room:IsFirstVisit() then
			if e.Variant == 10 or e.Variant == 20 or e.Variant == 30 or e.Variant == 40 or e.Variant == 50 or e.Variant == 51 or e.Variant == 52 or e.Variant == 53 or e.Variant == 60 or e.Variant == 69 or e.Variant == 70 or e.Variant == 90 or e.Variant == 300 or e.Variant == 360 then
				Isaac.Spawn(e.Type, e.Variant, 0, Isaac.GetFreeNearPosition(room:GetCenterPos(), 1.0), Vector(0, 0), player)
				wealth_pickup_spawned = true
			end
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.blessingWealth)

local doubtful_level_id = nil
local added_items_doubtful = false
local removed_items_doubtful = false

function _Stillbirth:blessingDoubtful()
	local player = Isaac.GetPlayer(0)
	if (bit.band(Game():GetLevel():GetCurses(), Curses.blessing_doubtful) ~= Curses.blessing_doubtful) then return end
	if not added_items_doubtful then
		player:AddCollectible(CollectibleType.COLLECTIBLE_THERES_OPTIONS, 0, false)
		player:AddCollectible(CollectibleType.COLLECTIBLE_MORE_OPTIONS, 0, false)
		added_items_doubtful = true
		removed_items_doubtful = false
	end
	doubtful_level_id = Game():GetLevel():GetStage()
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.blessingDoubtful)

function _Stillbirth:removeBlessingDoubtful()
	local player = Isaac.GetPlayer(0)
	if Game():GetLevel():GetStage() ~= doubtful_level_id and added_items_doubtful and not removed_items_doubtful then
		player:RemoveCollectible(CollectibleType.COLLECTIBLE_THERES_OPTIONS)
		player:RemoveCollectible(CollectibleType.COLLECTIBLE_MORE_OPTIONS)
		removed_items_doubtful = true
		added_items_doubtful = false
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.removeBlessingDoubtful)

--DISPLAY BLESSING NAME

function _Stillbirth:getNewLevelFramecount()
    g_vars.newLevelFrameCount = Game():GetFrameCount()
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, _Stillbirth.getNewLevelFramecount)

local spriteBlessing = {
                guide=Sprite(),
                light = Sprite(),
                doubtful = Sprite(),
                miracle = Sprite(),
                wealth = Sprite(),
                mighty = Sprite()
}
spriteBlessing.guide:Load("gfx/ui/blessings/blessing_of_the_guide.anm2", true)
spriteBlessing.light:Load("gfx/ui/blessings/blessing_of_enlightment.anm2", true)
spriteBlessing.doubtful:Load("gfx/ui/blessings/blessing_of_the_doubtful.anm2", true)
spriteBlessing.miracle:Load("gfx/ui/blessings/blessing_of_the_miracle.anm2", true)
spriteBlessing.wealth:Load("gfx/ui/blessings/blessing_of_the_wealthy.anm2", true)
spriteBlessing.mighty:Load("gfx/ui/blessings/blessing_of_the_mighty.anm2", true)

local pressed = false --the switch for rendering\not rendering the sprite
local halftick = false --trigger the update function only half the times you render
local spriteBlessing_position = Isaac.WorldToRenderPosition(Vector(320,280)) --position to render at
local empty_vector = Vector(0,0)

function handleTabAndFramerateForBlessings(sprite)
    local player = Isaac.GetPlayer(0)
    local nb = Game():GetFrameCount()-g_vars.newLevelFrameCount
    local delay = 60 --1sec
    local onScreenTime = 120 --2sec
    local condition_frames = (nb >= delay  and nb <= delay+onScreenTime)
    if condition_frames then
	    spriteBlessing_position = Isaac.WorldToRenderPosition(Vector(320,64))
	    sprite:Play("Text", true)
	end
	if Input.IsActionTriggered(ButtonAction.ACTION_MAP, player.ControllerIndex) then
	    spriteBlessing_position = Isaac.WorldToRenderPosition(Vector(320,64))
	    pressed = not pressed
		if pressed then
			sprite:Play("Text",true)
		end
	elseif pressed and not Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then 
	    pressed = not pressed 
	end
	if (pressed or condition_frames) then
		sprite:Render(spriteBlessing_position,empty_vector,empty_vector)
		if halftick then
			sprite:Update() --render and update the sprite at the given position
		end
	end
	--RenderText(condition_frames)
end

function _Stillbirth:displayBlessing()
    if currentBlessing == "guide" then
        handleTabAndFramerateForBlessings(spriteBlessing.guide)
    elseif currentBlessing == "light" then
        handleTabAndFramerateForBlessings(spriteBlessing.light)
    elseif currentBlessing == "doubtful" then
        handleTabAndFramerateForBlessings(spriteBlessing.doubtful)
    elseif currentBlessing == "miracle" then
        handleTabAndFramerateForBlessings(spriteBlessing.miracle)
    elseif currentBlessing == "wealth" then
        handleTabAndFramerateForBlessings(spriteBlessing.wealth)
    elseif currentBlessing == "mighty" then
        handleTabAndFramerateForBlessings(spriteBlessing.mighty)
    end
	halftick = not halftick
	--RenderText(currentBlessing, pressed, spriteBlessing:GetFilename(), spriteBlessing:IsLoaded())
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_RENDER, _Stillbirth.displayBlessing)

--[[
local sp = Sprite() --create a sprite
sp:Load("gfx/ui/blessings/blessing_of_enlightment.anm2",true) --load the anim file and the animation to play
local sp_position = Isaac.WorldToRenderPosition(Vector(320,280)) --position to render at
local empty_vector = Vector(0,0)
local pressed = false --the switch for rendering\not rendering the sprite
local halftick = false --trigger the update function only half the times you render

function _Stillbirth:onRender()
	local player = Isaac.GetPlayer(0)
	if Input.IsButtonTriggered(Keyboard.KEY_TAB, player.ControllerIndex) then
		pressed = not pressed
		if pressed then
			sp:Play("Text",true)
		end
		--switch between rendering and not rendering when T is pressed on the keyboard
	end
	if pressed then
		sp:Render(sp_position,empty_vector,empty_vector)
		if halftick then
			sp:Update() --render and update the sprite at the given position
		end
	end
	halftick = not halftick
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_RENDER, _Stillbirth.onRender)]]--
--monkey items curse negation

function _Stillbirth:MonkeyCurseUpdate(curse)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.mizaru_i) and (curse == 1 or curse == 1<<2) then
		return
	end
	if player:HasCollectible(Items.kikazaru_i) and (curse == 1<<1 or curse == 1<<5) then
		return
	end
 	if player:HasCollectible(Items.iwazaru_i) and (curse == 1<<6 or curse == 1<<3) then
 		return
 	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, _Stillbirth.MonkeyCurseUpdate)
