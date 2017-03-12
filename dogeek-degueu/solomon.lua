--[[
Item Passive Solomon
Réduit la barre d'HP à 6 coeurs max mais gros boost de stats

--Dogeek
]]--

local afterbrasse = RegisterMod("Afterbrasse", 1);
--local solomon = Isaac.GetItemIdByName("TestPassive")

function IsFullBlackHearts(player)  -- Usefull use of GetBlackHeart()
    return (function(n) local s = player:GetSoulHearts() for i=0, 12 do if (1<<i)-1 == n then return ((i*2)==s and true) or false end end return false end)( player:GetBlackHearts() )
end

function afterbrasse:SolomonCache(player, cacheFlag)
	local player = Isaac.GetPlayer(0)
    --if player:HasCollectible(solomon) then
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + 2
        end
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay - 3
        end
        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + 0.6
        end
        if cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + 3
        end
        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + 0.3
        end
    --end
end

function afterbrasse:SolomonUpdate()
    local player = Isaac.GetPlayer(0)
    --if player:HasCollectible(solomon) then
    	local entities = Isaac.GetRoomEntities()
        local redHearts = player:GetMaxHearts()
        local soulHearts = player:GetSoulHearts()
        if (redHearts+soulHearts > 12) then
		    if (soulHearts ~= 0) then
		        player:AddSoulHearts(-1)
				for i = 1, #entities do
					local e = entities[i]
		    		if e.Type == 5 and e.Variant == 10 and (e.SubType == HeartSubType.HEART_SOUL or e.SubType == HeartSubType.HEART_HALF_SOUL or e.SubType == HeartSubType.HEART_BLACK) then
		        		e.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		    		end
		    	end
		    else
		       player:AddMaxHearts(-2, false)
		    end
		elseif (redHearts+soulHearts)<12 or not IsFullBlackHearts(player) then
			for i = 1, #entities do
				local e = entities[i]
		    	if e.Type == 5 and e.Variant == 10 and (e.SubType == HeartSubType.HEART_SOUL or e.SubType == HeartSubType.HEART_HALF_SOUL or e.SubType == HeartSubType.HEART_BLACK) then
		        	e.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		    	end
		    end
		else
			for i = 1, #entities do
				local e = entities[i]
		    		if e.Type == 5 and e.Variant == 10 and (e.SubType == HeartSubType.HEART_SOUL or e.SubType == HeartSubType.HEART_HALF_SOUL or e.SubType == HeartSubType.HEART_BLACK) then
		        	e.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		    	end
		    end
        end
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
        player:AddCacheFlags(CacheFlag.CACHE_LUCK)
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
    --end
end

afterbrasse:AddCallback(ModCallbacks.MC_POST_UPDATE, afterbrasse.SolomonUpdate)
afterbrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, afterbrasse.SolomonCache) 
