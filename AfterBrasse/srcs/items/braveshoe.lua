--[[
Item: "Brave Shoe" Type: "passive item"
-xahos-
--]]

function AfterBrasse:take_damage(entity, dmg_amount, dmg_flag, dmg_src, dmg_countdown)
  player = Isaac.GetPlayer(0)

  if player:HasCollectible(Items.brave_shoe_i) then
    if (dmg_flag == DamageFlag.DAMAGE_SPIKES) then
      return false
    end
  end
  return true
end

function AfterBrasse:cacheUpdate(player, cacheFlag)
  if player:HasCollectible(Items.brave_shoe_i) then
    if (cacheFlag == CacheFlag.CACHE_SPEED) then
      player.MoveSpeed = player.MoveSpeed + 0.2;
    end
  end
end
AfterBrasse:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, AfterBrasse.take_damage, EntityType.ENTITY_PLAYER)
AfterBrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, AfterBrasse.cacheUpdate)
