--[[
Item: "Cricket's Paw" Type: "active item"
-Sliost-
--]]

--local global vars
local cricketsPawUses = 0
local hadCricketsPaw = false
function AfterBrasse:VarsInit() -- Variables who need initialisation/reinitialisation at every new game
	cricketsPawUses = 0
	hadCricketsPaw = false
end
function AfterBrasse:UseCricketsPaw()
  local player = Isaac.GetPlayer(0)
  local soulHearts = player:GetSoulHearts()

  if cricketsPawUses < 5 then
    -- More than 3 read hearts
    if player:GetMaxHearts() > 4 or (player:GetMaxHearts() == 4 and (player:GetBlackHearts() > 1 or soulHearts() >1)) then
      player:AddMaxHearts(-4)
      hadCricketsPaw = true
      cricketsPawUses = math.min(cricketsPawUses + 1,5)
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
      return true
    -- More than 3 full soul/black hearts
    elseif (player:GetMaxHearts() == 0 and soulHearts() > 6) or (player:GetMaxHearts() ~= 0 and soulHearts >= 6) then
      for i=1,6 do
        player:RemoveBlackHeart(soulHearts -i)
      end
      player:AddSoulHearts(-6)
      hadCricketsPaw = true
      cricketsPawUses = math.min(cricketsPawUses + 1,5)
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
      return true
    end
  end
end

function AfterBrasse:HasCricketsPawUsesCacheUpdate(player, cacheFlag)
  if hadCricketsPaw then
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
      for i=1, cricketsPawUses do
        player.Damage = player.Damage * 1.1 -- TO BALANCE
      end
    end
  end
end
--Cricket'sPaw
AfterBrasse:AddCallback(ModCallbacks.MC_USE_ITEM, AfterBrasse.UseCricketsPaw, Items.CricketsPaw_i)
AfterBrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, AfterBrasse.HasCricketsPawUsesCacheUpdate)
AfterBrasse:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,AfterBrasse.VarsInit)
