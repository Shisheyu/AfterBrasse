--[[
Item: "Money = Luck"  Type: "passive item"
-Krayz-
--]]

function AfterBrasse:MoneyLuck_obj()
	local player = Isaac.GetPlayer(0)
	if ( player:HasCollectible( Items.MoneyLuck_i ) ) then
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
	end
end
function AfterBrasse:MoneyLuck_UpdateStats(player, cacheFlag) --StatsUpdate Code
	local player = Isaac.GetPlayer(0)

	if ( player:HasCollectible( Items.MoneyLuck_i ) ) then
		if cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck  = player.Luck + (player:GetNumCoins()*0.05048)
		end
	end
end
--Money=Luck
AfterBrasse:AddCallback(ModCallbacks.MC_POST_UPDATE, AfterBrasse.MoneyLuck_obj);
AfterBrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, AfterBrasse.MoneyLuck_UpdateStats);
