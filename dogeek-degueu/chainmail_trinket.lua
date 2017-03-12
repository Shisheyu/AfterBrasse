--[[
Trinket : Chainmail pas de dégat sur les curse rooms
--Dogeek
]]--

local afterbrasse = RegisterMod("Afterbrasse", 1);
local chainmail = Isaac.GetTrinketIdByName("TestTrinket")

function afterbrasse:curseRoomUpdate(entity, dmg_amount, dmg_flag, dmg_src, dmg_countdown)
  player = Isaac.GetPlayer(0)

  if player:HasTrinket(chainmail) then
        if dmg_flag == DamageFlag.DAMAGE_CURSED_DOOR then
          return false
        end
  end
end

afterbrasse:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, afterbrasse.curseRoomUpdate, EntityType.ENTITY_PLAYER)
