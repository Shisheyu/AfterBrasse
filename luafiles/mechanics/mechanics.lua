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
