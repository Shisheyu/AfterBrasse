-- CREATED BY ILLUDAY
-- illuday.deviantart.com
-- @illuday

------------- INCLUDE ILLUDAY'S LIB
local debug = require('debug');
local currentSrc = string.gsub(debug.getinfo(1).source, "^@?(.+/)[^/]+$", "%1") .. '?.lua';
package.path = currentSrc .. ';' .. package.path;
require('libs.illuday');

------------- MOD PASSIVE STATS UP

local Illuday = RegisterMod("Passive Stats Up", 1);
local spawn = false;

function Illuday:PlayerInit(player)
    spawn = false; end

function Illuday:Render(_mod)
    Isaac.RenderText("Illuday - #1 PASSIVE STATS UP", 80, 50, 255, 255, 255, 255);
    if not spawn then
        spawn = true;
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 511, Vector(320, 280), Vector(0, 0), player);
    end
end

------------- ITEM

local item = Isaac.GetItemIdByName("illuday");
function Illuday:ItemStats(player, cacheFlag)
    if player:HasCollectible(item) then
        addStat(player, cacheFlag, "damage", 10);
        addStat(player, cacheFlag, "luck", 10);
        addStat(player, cacheFlag, "speed", 10);
        addStat(player, cacheFlag, "shotspeed", 10);
        addStat(player, cacheFlag, "tear-height", 10);
        addStat(player, cacheFlag, "tear-flags", 10);
        addStat(player, cacheFlag, "tear-falling", 10);

        -- FIRE DELAY not working in condition for now...
        player.MaxFireDelay = 2;
        -- then this isn't working :
        addStat(player, cacheFlag, "firedelay", -3);
    end
end

Illuday:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Illuday.ItemStats);
Illuday:AddCallback(ModCallbacks.MC_POST_RENDER, Illuday.Render);
Illuday:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Illuday.PlayerInit);