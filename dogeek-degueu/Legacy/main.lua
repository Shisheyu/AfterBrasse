--[[
Passive Item : Legacy : 1up avec revive aléatoire entre les personnages
-Dogeek-
]]--

local afterbrasse = RegisterMod("AfterBrasse", 1);
local legacy = Isaac.GetItemIdByName("Legacy");
local legacy_variant = Isaac.GetEntityVariantByName("Legacy");

local function onFamiliarUpdate(_, fam)
	local player = Isaac.GetPlayer(0)
	fam:FollowPosition(player.Position);
	if player.isDead() == true and player.WillPlayerRevive == false then
		player.Revive();
		player.UseActiveItem(COLLECTIBLE_CLICKER, false, false, false, false);
		fam.Remove();
	end
end


local function onInit(_, fam)
	local player = Isaac.GetPlayer(0)
end

local function onEvaluateCache(_, _, cacheFlag)
    local player = Isaac.GetPlayer(0)
   
    if cacheFlag == CacheFlag.CACHE_FAMILIARS and player:HasCollectible(legacy) then
        local e = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, legacy_variant, 0, player.Position, Vector(0, 0), player);
    end
end

afterbrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onEvaluateCache);
afterbrasse:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onInit, legacy_variant);
afterbrasse:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onFamiliarUpdate, legacy_variant);
