--[[
Cataract : Epiphora pour le dommage et le tear delay
--Dogeek
]]--


local afterbrasse = RegisterMod("Afterbrasse", 1);
local cataract = Isaac.GetItemIdByName("TestPassive");

local numberOfTearsShot = 0
local previousDirection = -1
local baseDamage
local baseShotSpeed

local function IsShooting(player)
	if player:GetFireDirection() == -1 then
		return false
	else
		return true
	end
end

local function numberToAdd()
	local cataractRate = 10
	if numberOfTearsShot <= 4*cataractRate then
		return math.floor(numberOfTearsShot/cataractRate)
	else
		return 4
	end
end

function afterbrasse:cataract_cache(player, cacheFlag)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(cataract) then
		if IsShooting(player) then
			if cacheFlag == CacheFlag.CACHE_DAMAGE or cacheFlag == CacheFlag.CACHE_SHOTSPEED then
				player.Damage = player.Damage +  numberToAdd()
				player.ShotSpeed = player.ShotSpeed - 0.1*numberToAdd()
				if player:GetFireDirection() ~= previousDirection then
					numberOfTearsShot = 0
					player.Damage = baseDamage
					player.ShotSpeed = baseShotSpeed
				end
			end
		else
			numberOfTearsShot = 0
			player.Damage = baseDamage
			player.ShotSpeed = baseShotSpeed
		end
	end
end

function afterbrasse:cataract_update()
	player = Isaac.GetPlayer(0)
	if not IsShooting(player) then
		baseDamage = player.Damage
		baseShotSpeed = player.ShotSpeed
	end
	if player:HasCollectible(cataract) then
		if IsShooting(player) then
        	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        	player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
        	player:EvaluateItems()
			if (Game():GetFrameCount()%player.MaxFireDelay == 0) then
				numberOfTearsShot = numberOfTearsShot + 1
			end
		end
		previousDirection = player:GetFireDirection()
	end
end

afterbrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, afterbrasse.cataract_cache)
afterbrasse:AddCallback(ModCallbacks.MC_POST_UPDATE, afterbrasse.cataract_update)
