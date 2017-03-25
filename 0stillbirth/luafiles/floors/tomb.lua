function _Stillbirth:GenerateTomb()
	local level = Game():GetLevel()
	local player = ISaac.GetPlayer(0)
	if isNextFloorTomb then
		overlay = Sprite()
		--overlay:Load("/gfx/backdrop/tomb_backdrop.anm2", true)
		--overlay:Render(Game():GetRoom():GetRenderSurfaceTopLeft(), Vector(0,0), Vector(0,0))
        --overlay:Play("Stage",false)
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, _Stillbirth.GenerateTomb)

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
	if getDistance(player.Position, ropePos) and ropeHasSpawned then
		isNextFloorTomb = true
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.AddRope)
