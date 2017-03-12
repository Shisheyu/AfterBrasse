--[[
Trinket : Chainmail pas de dégat sur les curse rooms
--Dogeek
]]--

function _Stillbirth:curseRoomUpdate(entity, dmg_amount, dmg_flag, dmg_src, dmg_countdown)
  player = Isaac.GetPlayer(0)

  if player:HasTrinket(Trinkets.chainmail_t) then
        if dmg_flag == DamageFlag.DAMAGE_CURSED_DOOR then
          return false
        end
  end
end

_Stillbirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.curseRoomUpdate, EntityType.ENTITY_PLAYER)
