-- CREATED BY ILLUDAY
-- illuday.deviantart.com
-- @illuday

-- TODO: IN EVALUATE_CACHE CALLBACK
-- WARN: FIREDELAY NOT WORKING NOW 01-14-2017
-- stat == damage, firedelay, shotspeed, speed, range, luck
-- THINK TO ADD CACHE VALUE IN ITEMS.XML
function addStat(player, cacheFlag, statName, stat)
    if cacheFlag == CacheFlag.CACHE_DAMAGE and statName == "damage" then
        player.Damage = player.Damage + stat;
    elseif cacheFlag == CacheFlag.CACHE_FIREDELAY and statName == "firedelay" then
        player.MaxFireDelay = player.MaxFireDelay + stat;
    elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED and statName == "shotspeed" then
        player.ShotSpeed = player.ShotSpeed + stat;
    elseif cacheFlag == CacheFlag.CACHE_SPEED and statName == "speed" then
        player.MoveSpeed = player.MoveSpeed + stat;
    elseif cacheFlag == CacheFlag.CACHE_LUCK and statName == "luck" then
        player.Luck = player.Luck + stat;
    elseif cacheFlag == CacheFlag.CACHE_RANGE and statName == "tear-height" then
        player.TearHeight = player.TearHeight + 30;
    elseif cacheFlag == CacheFlag.CACHE_RANGE and statName == "tear-flags" then
        player.TearFlags = player.TearFlags + 30;
    elseif cacheFlag == CacheFlag.CACHE_RANGE and statName == "tear-falling" then
        player.TearFallingSpeed = player.TearFallingSpeed + 30;  end
end


