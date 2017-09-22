require("luafiles/mechanics/curses")
require("luafiles/mechanics/pills")
require("luafiles/mechanics/transformations")
require("luafiles/mechanics/character_init")
--require("luafiles/mechanics/devil_boss")
--require("luafiles/mechanics/cards")

PICKED_COLLECTIBLES = {}
PICKED_ACTIVE_COLLECTIBLES = {}
PICKED_PASSIVE_COLLECTIBLES = {}
TRACK_COLLECTIBLES = 0
function _Stillbirth:onInitResetTracker()
	PICKED_ACTIVE_COLLECTIBLES = {}
	PICKED_COLLECTIBLES = {}
	PICKED_PASSIVE_COLLECTIBLES = {}
	TRACK_COLLECTIBLES = 0
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, _Stillbirth.onInitResetTracker)

function _Stillbirth:TrackItems()
	local player = Isaac.GetPlayer(0)
	local TotalItems = 520 + 500
	if player:GetCollectibleCount() > TRACK_COLLECTIBLES or not has_value(PICKED_ACTIVE_COLLECTIBLES, player:GetActiveItem()) then
		TRACK_COLLECTIBLES = player:GetCollectibleCount()
		for i=1, TotalItems do
			if player:HasCollectible(i) and not has_value(PICKED_COLLECTIBLES, i) then
				table.insert(PICKED_COLLECTIBLES, i)
				if isActiveCollectible(i) then
					table.insert(PICKED_ACTIVE_COLLECTIBLES, i)
				elseif isPassiveCollectible(i) then
					table.insert(PICKED_PASSIVE_COLLECTIBLES, i)
				end
			end
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.TrackItems)

function _Stillbirth:GiantBookRender()
	local v = Vector(0, 0)
	if not GiantBooks.dadsbeer:IsFinished("Shake") then
		GiantBooks.dadsbeer:Render(Isaac.WorldToRenderPosition(Vector(320,280)), v, v)
		if GiantBooks.halftick then GiantBooks.dadsbeer:Update() end
	end
	if not GiantBooks.medusa:IsFinished("Appear") then
		GiantBooks.medusa:Render(Isaac.WorldToRenderPosition(Vector(320,280)), v, v)
		if GiantBooks.halftick then GiantBooks.medusa:Update() end
	end
	if not GiantBooks.encyclopedia:IsFinished("Appear") then
		GiantBooks.encyclopedia:Render(Isaac.WorldToRenderPosition(Vector(320,280)), v, v)
		if GiantBooks.halftick then GiantBooks.encyclopedia:Update() end
	end
	if not GiantBooks.goldenidol:IsFinished("Appear") then
		GiantBooks.goldenidol:Render(Isaac.WorldToRenderPosition(Vector(320,280)), v, v)
		if GiantBooks.halftick then GiantBooks.goldenidol:Update() end
	end
	GiantBooks.halftick = not GiantBooks.halftick
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_RENDER, _Stillbirth.GiantBookRender)

function _Stillbirth:FreezeEntities()
	local player = Isaac.GetPlayer(0)
	--print(Game():GetFrameCount(), g_vars.framecount_stop)
	local entities = Isaac.GetRoomEntities()
	if g_vars.freezeentities_init >=1 then
		if g_vars.framecount_stop >= Game():GetFrameCount() then
			for i=1, #entities do
				if g_vars.freezeentities_init == 1 then
					table.insert(frictionEntities, entities[i].Friction)
					table.insert(velocityEntities, entities[i].Velocity)
				end
				entities[i].Velocity = Vector(0,0)
				entities[i].Friction = 0
			end
			g_vars.freezeentities_init = 2
		elseif g_vars.freezeentities_init == 2 and g_vars.framecount_stop < Game():GetFrameCount() then
			for i=1, #entities do
				entities[i].Velocity = velocityEntities[i]
				entities[i].Friction = frictionEntities[i]
			end
			frictionEntities = {}
			velocityEntities = {}
			g_vars.freezeentities_init = 0
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.FreezeEntities)
