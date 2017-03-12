local Afterbrasse = RegisterMod("Mizaru", 1);
local mizaru_item = Isaac.GetItemIdByName("Mizaru");
local rng = nil
local need_rng = true
local accuracy = 100
local n = 0

function Afterbrasse:MizaruUpdate()
    if need_rng then
    	rng = math.random(-0.75*player.MaxFireDelay*accuracy, 1.25*player.MaxFireDelay*accuracy)/accuracy;
    end
    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
    player:EvaluateItems()
end

function Afterbrasse:MizaruCache(player, cacheFlag)
    if player:HasCollectible(mizaru_item) and cacheFlag == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = player.MaxFireDelay + FireDelayToAdd()
    end
end

function FireDelayToAdd()
	n = n + (1/accuracy)
	if rng>0 then
		if n<rng then
			need_rng = false
			return rng + n
		else
			n = 0
			need_rng = true
			return 0
		end
	elseif rng == 0 then
		return 0
	else
		if n>rng then
			need_rng = false
			return rng - n
		else
			n = 0
			need_rng = true
			return 0
		end
	end
end

Afterbrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Afterbrasse.MizaruCache)
Afterbrasse:AddCallback(ModCallbacks.MC_POST_UPDATE, Afterbrasse.MizaruUpdate)
