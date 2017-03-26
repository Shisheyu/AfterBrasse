--[[
Trinket : Chainmail pas de degat sur les curse rooms
--Dogeek
--]]

function _Stillbirth:curseRoomUpdate(entity, dmg_amount, dmg_flag, dmg_src, dmg_countdown)
  player = Isaac.GetPlayer(0)

  if player:HasTrinket(Trinkets.chainmail_t) then
        if dmg_flag == DamageFlag.DAMAGE_CURSED_DOOR then
          return false
        end
  end
end
_Stillbirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.curseRoomUpdate, EntityType.ENTITY_PLAYER)

--[[
Trinket : Krampus's Tooth
-Drazeb-
--]]

function _Stillbirth:krampusToothUpdate()
   local game = Game()
   local player = Isaac.GetPlayer(0)

   -- Si trinket alors Krampus est set a  "rencontre"
   if player:HasTrinket(Trinkets.kramp_tooth_t) then
        game:SetStateFlag(GameStateFlag.STATE_KRAMPUS_SPAWNED, true)
   -- Sinon verifier qu'on a rencontre krampus
   else
        local status_kramp = game:HasEncounteredBoss(EntityType.ENTITY_FALLEN, 1)
        game:SetStateFlag(GameStateFlag.STATE_KRAMPUS_SPAWNED, status_kramp)
   end
end
_Stillbirth:AddCallback( ModCallbacks.MC_POST_UPDATE, _Stillbirth.krampusToothUpdate)

--[[
Trinket Green Cross : Challenge Down
--Dogeek
--]]
function _Stillbirth:GreenCrossUpdate()
    local player = Isaac.GetPlayer(0)
    local entities = Isaac.GetRoomEntities()
    local room = Game():GetRoom()

    if player:HasTrinket(Trinkets.greenCross_t) then
    	if g_vars.greencross_lastRoom ~= room:GetDecorationSeed() then
    		for i=1, #entities do
    			local e = entities[i]
    			if e:IsVulnerableEnemy() then
    				if e:ToNPC():IsChampion() then
    					--Isaac.Spawn(e.Type, e.Variant, 0, e.Position, e.Velocity, e.SpawnerEntity) --essai de faire spawn le mob en normal avant d'enlver le champion, ne marche pas.
    					--Game():RerollEnnemy(e:ToNPC())
    					e:Remove() --comment changer un champion en non champion ? pour le moment supprime les mobs champions
    				end
    			end
    		end
    		g_vars.greencross_lastRoom = room:GetDecorationSeed()
    	end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.GreenCrossUpdate)

--[[
Trinket : Torn gloves
-Slyhawks-
--]]

function _Stillbirth:tornGloves_take_damage(entity, dmg_amount, dmg_flag, dmg_src, dmg_countdown)
	player = Isaac.GetPlayer(0)
	if (player:HasTrinket(Trinkets.torn_gloves_t)) then
		if (dmg_flag == DamageFlag.DAMAGE_CHEST) then
			return false
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.tornGloves_take_damage, EntityType.ENTITY_PLAYER)
