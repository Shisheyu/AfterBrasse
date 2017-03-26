--bug bit avec miracle???? doubtful ne s'enlève pas et wealth fait spawn des piedestaux en plus

local NUM_BLESSINGS = 6 --6
local currentBlessing = ""

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
			currentBlessing = "Blessing of the ".."guide"
			return bit.bor(Curses.blessing_guide, curse)
		elseif rand == 2 then
			currentBlessing = "Blessing of the ".."light"
			return bit.bor(Curses.blessing_light, curse)
		elseif rand == 3 then
			currentBlessing = "Blessing of the ".."miracle"
			return bit.bor(Curses.blessing_miracle, curse)
		elseif rand == 4 then
			currentBlessing = "Blessing of the ".."acceptance"
			return bit.bor(Curses.blessing_acceptance, curse)
		elseif rand == 5 then
			currentBlessing = "Blessing of the ".."wealth"
			return bit.bor(Curses.blessing_wealth, curse)
		elseif rand == 6 then
			currentBlessing = "Blessing of the ".."doubtful"
			return bit.bor(Curses.blessing_doubtful, curse)
		else
			currentBlessing = ""
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

function _Stillbirth:displayBlessing()
	local room = Game():GetRoom()
	Isaac.RenderText(currentBlessing, 50, 20, 255, 255, 255, 255)
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_RENDER, _Stillbirth.displayBlessing)

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
