--[[
Item : none
Type : Keeper now holds greed's gullet, head of the keeper and swallowed penny
By : Dogeek
Date : 2017-03-07
]]--

-----------------------------
-- POST PLAYER INIT VARIABLES
-----------------------------
function REBALANCE_InitKeeper()
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() == PlayerType.PLAYER_KEEPER then
		if not player:HasCollectible(501) then --greed's gullet'
			player:AddCollectible(501, 0, true)
		end
		--[[
		if not player:HasCollectible(429) then --head of the keeper
			player:AddCollectible(429, 0, true)
		end
		if not player:HasTrinket(1) then -- swallowed penny
			player:AddTrinket(1)
		end
		--]]
	end
end

--~ _Stillbirth:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,_Stillbirth.InitKeeper)

--[[
Item : Ottid
Init to give a puberty pill for adulthood transfo
]]--

function _Stillbirth:InitOttid(player)
	g_vars.ottid_pillGiven = false
end

_Stillbirth:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,_Stillbirth.InitOttid)
