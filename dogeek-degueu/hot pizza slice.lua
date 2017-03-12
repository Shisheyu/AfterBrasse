--[[
Passive Item : Hot Pizza Slice : Damage up, size up et 1 soul heart
-Dogeek-
]]--

local afterbrasse = RegisterMod("AfterBrasse", 1);
local hot_pizza_slice = Isaac.GetItemIdByName("Hot Pizza Slice");

function afterbrasse:cacheUpdate(player, cacheFlag)
	local player = Isaac.GetPlayer(0)

	if player:HasCollectible(hot_pizza_slice) == true then
		if (cacheFlag == CacheFlag.CACHE_DAMAGE) then
			player.Damage = player.Damage + 1;
		end
		player.Size = player.Size + 1;
		player.AddSoulHearts(1);
	end
end

afterbrasse:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, afterbrasse.cacheUpdate);
