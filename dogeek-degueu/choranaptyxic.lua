--[[
Item Passive : Choranaptyxic : Stats basées sur grande ou petite salle. Salle neutre ne modifie pas
--Dogeek

Tear rate + speed petite
Range + damage dans les grandes
]]--

local afterbrasse = RegisterMod("Afterbrasse", 1);
--local choranaptyxic = Isaac.GetItemIdByName("TestPassive")

local bdmg = 0
local brange = 0
local bspeed = 0
local btears = 1
local lastShape = 0

function afterbrasse:ChoranaptyxicCache(player, cacheFlag)
    local player = Isaac.GetPlayer(0)
    --if player:HasCollectible(choranaptyxic) then
        if cacheFlag==CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + bdmg
        end
           if cacheFlag==CacheFlag.CACHE_RANGE then
            player.TearHeight = player.TearHeight + brange
        end
        if cacheFlag==CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + bspeed
        end
        if cacheFlag==CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay*btears
        end
    --end
end

function afterbrasse:ChoranaptyxicUpdate()
    local player = Isaac.GetPlayer(0)
    local entities = Isaac.GetRoomEntities()
    local roomShape = Game():GetRoom():GetRoomShape()
    --if player:HasCollectible(choranaptyxic) then
		if roomShape ~= lastShape then
			if roomShape == RoomShape.ROOMSHAPE_IH or roomShape == RoomShape.ROOMSHAPE_IV or roomShape == RoomShape.ROOMSHAPE_IIV or roomShape == RoomShape.ROOMSHAPE_IIH then
				bdmg = 0
				brange = 0
				bspeed = 1
				btears = 0.5
			elseif roomShape == RoomShape.ROOMSHAPE_1x2 or roomShape == RoomShape.ROOMSHAPE_2x1 or roomShape == RoomShape.ROOMSHAPE_2x2 or roomShape == RoomShape.ROOMSHAPE_LTL or roomShape == RoomShape.ROOMSHAPE_LTR or roomShape == RoomShape.ROOMSHAPE_LBL or roomShape == RoomShape.ROOMSHAPE_LBR then
				bdmg = 2
				brange = -10
				bspeed = 0
				btears = 1
			else
				bdmg = 0
				brange = 0
				bspeed = 0
				btears = 1
			end
			
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:AddCacheFlags(CacheFlag.CACHE_RANGE)
			player:EvaluateItems()
		end
    --end
	lastShape = roomShape
end

afterbrasse:AddCallback(ModCallbacks.MC_POST_UPDATE, afterbrasse.ChoranaptyxicUpdate)
afterbrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, afterbrasse.ChoranaptyxicCache) 
