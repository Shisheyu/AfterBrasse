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

--[[
Trinket : Rusty Crowbar : permet de bomber le chest
-Dogeek-
jouer l'animation des portes qui cassent et les maintenir cassées
--]]

function _Stillbirth:rustyCrowbar_update()
    local player = Isaac.GetPlayer(0)
    if player:HasTrinket(Trinkets.rustyCrowbar_t) then
        local stage = Game():GetLevel():GetAbsoluteStage()
	    if stage >= 11 then --chest and after (void and custom floors)
		    local currentRoom = Game():GetRoom()
		    if currentRoom:IsInitialized() then
			    for i=1, #SLOTS do
				    local door = currentRoom:GetDoor(SLOTS[i])
				    if currentRoom:IsDoorSlotAllowed(SLOTS[i]) and door ~= nil then
					    if explosionInRange(door) then
						    door.Busted = true
						    door:Open()
						    local doorSprite = door.Sprite
						    doorSprite:Play("Break", true);
					    end
				    end
			    end
		    end
	    end
    end
end

_Stillbirth:AddCallback( ModCallbacks.MC_POST_UPDATE, _Stillbirth.rustyCrowbar_update);

--[[
Trinket : ?
Random passive item every room
--Dogeek
]]--

function _Stillbirth:questionMark_NewRoomUpdate()
    local player = Isaac.GetPlayer(0)
    if player:HasTrinket(Trinkets.question_mark_t) then
        if g_vars.questionmark_item then
            player:RemoveCollectible(g_vars.questionmark_item)
        end
        repeat g_vars.questionmark_item = ItemPools.PASSIVES[math.random(#ItemPools.PASSIVES)] until not player:HasCollectible(g_vars.questionmark_item)
        player:AddCollectible(g_vars.questionmark_item, 0, false)
    else
        if g_vars.questionmark_item then
            player:RemoveCollectible(g_vars.questionmark_item)
            g_vars.questionmark_item = nil
        end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, _Stillbirth.questionMark_NewRoomUpdate)
