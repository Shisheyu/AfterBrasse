function _Stillbirth:GenerateTomb()
	local level = Game():GetLevel()
	local player = Isaac.GetPlayer(0)
	if isNextFloorTomb then
		overlay = Sprite()
		overlay:Load("/gfx/backdrop/void_overlay.anm2", true)
		overlay:Render(Game():GetRoom():GetRenderSurfaceTopLeft(), Vector(0,0), Vector(0,0))
        overlay:Play("Stage",true)
	end
end
--_Stillbirth:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, _Stillbirth.GenerateTomb)

local ropePos = nil
local ropeHasSpawned = false
local isNextFloorTomb = false

function _Stillbirth:newRunReset()
	ropePos = nil
	ropeHasSpawned = false
	isNextFloorTomb = false
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, _Stillbirth.newRunReset)

function _Stillbirth:onNewRoomReset()
	ropeHasSpawned = false
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, _Stillbirth.onNewRoomReset)

function _Stillbirth:AddRope()
	local player = Isaac.GetPlayer(0)
	local level = Game():GetLevel()
	if level:GetStage() == LevelStage.STAGE5 then
		ropePos = Vector(96,128)
	else
		ropePos = nil
	end
	if ropePos and not ropeHasSpawned and level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() then
		e = Isaac.Spawn(CustomEntities.RopeGridEntity, 0, 0, ropePos, Vector(0,0), player)
		e.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		e.GridCollisionClass = GridCollisionClass.COLLISION_WALL
		ropeHasSpawned = true
	end
	if ropePos then
		if getDistance(player.Position, ropePos) < 32 and ropeHasSpawned then
			isNextFloorTomb = true
			player:AnimateLightTravel()
			level:SetStage(LevelStage.STAGE1_1, StageType.STAGETYPE_AFTERBIRTH)
			local active = player:GetActiveItem()
			player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, false, false, true, false)
			--player:AddCollectible(active)
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.AddRope)
