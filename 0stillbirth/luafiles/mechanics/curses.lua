local NUM_BLESSINGS = 4 --6
local currentBlessing = ""
require("luafiles/libs/luabit/bit")

local collectibleHasSpawned = false
local wealth_pickup_spawned = false

function _Stillbirth:useBlessing(curse)
	local player = Isaac.GetPlayer(0)
	if curse == LevelCurse.CURSE_NONE and not player:HasCollectible(Items.white_candle_i) then
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
			return bit.bor(blessing_miracle, curse)
		elseif rand == 4 then
			currentBlessing = "Blessing of the ".."acceptance"
			return bit.bor(blessing_acceptance, curse)
		--[[
		elseif rand == 5 then
			currentBlessing = "Blessing of the ".."wealth"
			return bit.bor(blessing_wealth, curse)
		elseif rand == 6 then
			currentBlessing = "Blessing of the ".."doubtful"
			return bit.bor(blessing_doubtful, curse)]]--
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

local blessing_miracle_heal = false
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
	if (bit.band(Game():GetLevel():GetCurses(), Curses.blessing_acceptance) ~= Curses.blessing_acceptance or player:HasCollectible(CollectibleType.COLLECTIBLE_CHAMPIONS_BELT) or player:HasTrinket(TrinketType.TRINKET_PURPLE_HEART)) then return end
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
--[[
function _Stillbirth:blessingWealth()
	if (bit.band(Game():GetLevel():GetCurses(), Curses.blessing_wealth) ~= Curses.blessing_wealth) then return end
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()
	local room = Game():GetRoom()
	if not room:IsClear() then
		for i=1, #entities do
			if entities[i]:IsActiveEnemy() then
				hadEnemies = true
			end
		end
	end
	if room:GetFrameCount() == 1 then
		wealth_pickup_spawned = false
	end
	for i=1, #entities do
		local e = entities[i]
		if e.Type == 5 and (e.Variant ~= 100 or e.Variant ~= 150 or e.Variant ~= 380 or e.Variant ~= 350 or e.Variant ~= 370 or e.Variant ~= 340) and not wealth_pickup_spawned and hadEnemies then
			Isaac.Spawn(e.Type, e.Variant, 0, Isaac.GetFreeNearPosition(room:GetCenterPos(), 1.0), Vector(0, 0), player)
			wealth_pickup_spawned = true
			hadEnemies = false
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.blessingWealth)

function _Stillbirth:blessingDoubtful()
	if (bit.band(Game():GetLevel():GetCurses(), Curses.blessing_doubtful) ~= Curses.blessing_doubtful) then return end
	local bossPool = {15, 346, 438, 254, 342, 198, 25, 340, 165, 354, 24, 23, 240, 70, 343, 100, 22, 194, 12, 193, 253, 344, 195, 30, 31, 355, 29, 370, 219, 428, 141, 51, 218, 183, 341, 32, 27, 14, 26, 339, 255, 143, 196, 176, 92, 345, 28, 101, 92, 458, 455, 456, 454}
	local itemPool = {191, 245, 359, 15, 74, 320, 188, 491, 493, 465, 214, 161, 222, 443, 300, 308, 272, 506, 231, 274, 391, 473, 279, 7, 509, 157, 273, 140, 125, 131, 353, 19, 129, 8, 144, 385, 209, 377, 319, 497, 301, 307, 162, 62, 154, 69, 453, 457, 466, 369, 224, 4, 48, 371, 316, 170, 278, 117, 373, 336, 446, 237, 113, 469, 57, 445, 52, 265, 236, 381, 168, 368, 496, 310, 410, 240, 401, 404, 361, 467, 257, 128, 364, 418, 405, 318, 163, 495, 225, 432, 460, 210, 398, 206, 10, 167, 269, 374, 313, 178, 375, 256, 470, 242, 234, 148, 149, 201, 276, 494, 311, 266, 388, 440, 502, 332, 444, 270, 302, 304, 362, 384, 435, 471, 275, 277, 447, 96, 88, 99, 100, 87, 213, 365, 46, 411, 312, 12, 53, 394, 449, 202, 436, 71, 173, 110, 200, 55, 114, 228, 508, 217, 109, 322, 229, 106, 431, 153, 5, 317, 271, 378, 6, 426, 121, 120, 115, 75, 430, 461, 227, 309, 169, 261, 281, 379, 407, 223, 190, 174, 267, 95, 14, 72, 268, 221, 389, 189, 94, 172, 220, 306, 321, 142, 366, 305, 390, 393, 448, 459, 280, 67, 264, 330, 143, 91, 89, 211, 3, 176, 367, 138, 315, 463, 92, 299, 395, 244, 152, 68, 180, 334, 103, 101, 2, 329, 333, 151, 104, 155, 98, 1, 335, 13, 108, 358, 314, 233, 150, 350, 397, 452, 303, 76, 492, 392, 65, 136, 286, 186, 42, 78, 287, 58, 288, 504, 294, 482, 160, 437, 406, 489, 175, 481, 124, 85, 47, 291, 127, 485, 158, 283, 285, 386, 476, 166, 284, 39, 41, 123, 86, 37, 77, 147, 478, 146, 137, 292, 325, 507, 49, 382, 352, 422, 282, 323, 40, 421, 56, 295, 351, 488, 427, 102, 171, 192, 44, 419, 111, 97, 105, 93, 66, 107, 36, 324, 298, 484, 45} --actives après le 65 (inclus)
	local room = Game():GetRoom()
	local roomType = room:GetType()
	local CollectibleCount = 0
	if (roomType == RoomType.ROOM_BOSS or roomType == RoomType.ROOM_TREASURE) then
		for i=1, #entities do
			e = entities[i]
			if e.Type == 5 and e.Variant == 100 then
				CollectibleCount = CollectibleCount+1
			end
		end
		if CollectibleCount <= 1 then
			collectibleHasSpawned = false
		end
		if CollectibleCount == 2 then
			for i=i, #entities do
				e = entities[i]
				if e.Type == 5 and e.Variant == 100 and math.abs((player.Position-e.Position):Length()) <= 28 then
					player:AddCollectible(e.SubType, 0, true)
					player:FullCharge()
					e:Remove()
				end
			end
		end
	end
	if not collectibleHasSpawned then
		if roomType == RoomType.ROOM_BOSS then
			local rand = math.random(#bossPool)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, bossPool[i], Game():GetRoom():GetCenterPos(), Vector(0, 0), player)
			collectibleHasSpawned = true
		elseif roomType == RoomType.ROOM_TREASURE then
			local rand = math.random(#itemPool)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemPool[i], Game():GetRoom():GetCenterPos(), Vector(0, 0), player)
			collectibleHasSpawned = true
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.blessingDoubtful)
]]--
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
