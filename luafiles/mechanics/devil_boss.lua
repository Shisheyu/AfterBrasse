local fallen_entity = nil
local spawned_reward = false
local previousLevel = nil

function _Stillbirth:CheckDevilStatueBombed()
	local entities = Isaac.GetRoomEntities()
	local room = Game():GetRoom()
	local devilStatue = nil
	local lastBombTested = {}
    lastBombTested.Position = Vector(0xFFFFFF, 0xFFFFFF)
    local bombTested
	if room:GetType() == RoomType.ROOM_DEVIL then
		for i=1, #entities do
			if entities[i].Type == 1000 and entities[i].Variant == EffectVariant.DEVIL then
				devilStatue = entities[i]
			end
			if entities[i].Type == 4 and has_value(BombVariant, entities[i].Variant) then
				bombTested = entities[i]
            	if (devilStatue.Position:__sub(bombTested.Position)):Length() <= devilStatue.Position:__sub(lastBombTested.Position):Length() then
                	distanceBombdevilStatue = math.min((devilStatue.Position - bombTested.Position):Length(), (devilStatue.Position - lastBombTested.Position):Length())
                	lastBombTested = bombTested
            	end
			end
		end
		if type(lastBombTested) == "userdata"  and 96.0 >= distanceBombDoor and lastBombTested:IsDead() then
        	fallen_entity = Isaac.Spawn(EntityType.ENTITY_FALLEN, 0, 0, devilStatue.Position, Vector(0,0), devilStatue)
        	devilStatue:Remove()
        end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.CheckDevilStatueBombed)

function _Stillbirth:SpawnFallenReward()
	local rewards = {297, 133, 145, 81, 215, 212, 134, 102, 216, 241, 240, 225, 262, 195, 14, 143, 13, 70, 126, 35, 84, 8, 278, 259, 113, 163, 269, 51, 268, 172, 67, 79, 122, 275, 82, 80, 265, 115, 150, 270, 310, 336, 62, 273, 140, 188, 325, 107, 475, 487, 491, 496, 503, 345, 417, 371, 316, 441, 477, 408, 391, 420, 412, 498, 409, 431, 433, 468, 442, 462, 508, 451, 481, 124, 352, 507, 359, 506, 391, 509, 466, 446, 87, 411, 449, 389, 393, 448, 452, 358}
	local player = Isaac.GetPlayer(0)
	local pos = Game():GetRoom():GetCenterPos()
	if fallen_entity then
		if fallen_entity:IsDead() and not spawned_reward then
			local rand = math.random(#rewards)
			Isaac.Spawn(5, 100, rand, pos, Vector(0,0), player)
			spawned_reward = true
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.SpawnFallenReward)

function _Stillbirth:resetSpawnedRewardFlag()
	local currentStage = Game():GetLevel():GetStage()
	if currentStage ~= previousLevel then
		spawned_reward = false
	end
	previousLevel = currentStage
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.resetSpawnedRewardFlag)
