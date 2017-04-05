
dbz = "loaded"

local tearLeaf_t = nil
local tearLeaf_boss = nil

function _Stillbirth:mc_entity_take_dmg(entity, dmg_amount, dmg_flag, dmg_src, dmg_countdown)
	local player =  Isaac.GetPlayer(0)
	if entity then
		if entity.Type == 1 then -- player_mc_entity_take_dmg
			db_z = "player_mc_entity_take_dmg"

			--[[
			Trinket : Chainmail pas de degat sur les curse rooms
			--Dogeek
			--]]
			if player:HasTrinket(Trinkets.chainmail_t) then
				if dmg_flag == DamageFlag.DAMAGE_CURSED_DOOR then
					return false
				end
			end

			--[[
			Trinket : Torn gloves
			-Slyhawks-
			--]]
			if (player:HasTrinket(Trinkets.torn_gloves_t)) then
				if (dmg_flag == DamageFlag.DAMAGE_CHEST) then
					return false
				end
			end

			--[[
			Iwazaru
			-- "Baillon qui se met sur la bouche. Quand le joueur se fait toucher, le baillon active un shoop dawoop (1 fois par salle)"
			Sliost & Dogeek(pour finir l'item)
			--]]
			if player:HasCollectible(Items.iwazaru_i) and not g_vars.iwazaru_fired then
				g_vars.iwazaru_fired = true
				local angle = player:GetAimDirection():GetAngleDegrees()
				local shoop = EntityLaser.ShootAngle(3,player.Position,angle,30,Vector(0,-20),player)
				shoop.CollisionDamage = 2 -- TODO : Adjust value?
			end

			--[[
			Passive item: "Brave Shoe"
			-xahos-
			--]]
			local roomType = Game():GetRoom():GetType()
			if player:HasCollectible(Items.brave_shoe_i) then
				if (dmg_flag == DamageFlag.DAMAGE_SPIKES and roomType ~= RoomType.ROOM_SACRIFICE) then
					return false
				end
			end
		else -- other_mc_entity_take_dmg
			db_z = "other_mc_entity_take_dmg"

			--[[
				-Krayz
				Leaf Tear Effect for bubble's head and sunwukong
			--]]
			if entity:IsVulnerableEnemy() then -- for effects applying on vulnerable enemies
				if dmg_src.Type == 2 and dmg_src.Variant == CustomEntities.TearLeaf_Variant then
					if entity:IsBoss() then --boss differenciation
						tearLeaf_t = Isaac.GetFrameCount()
						tearLeaf_boss = entity
						entity:AddEntityFlags( 1 << 7 ) -- Slow flag
						entity:SetColor( Color( 0.8, 0.8, 0.8, 0.85, 120, 120, 120 ), 180, 50, false, false ) -- StopWatch like color
					else
						entity:AddEntityFlags( 1 << 7 ) -- Slow flag
						entity:SetColor( Color( 0.8, 0.8, 0.8, 0.85, 120, 120, 120 ), 9999, 50, false, false ) -- StopWatch like color
					end
				end
			end

			--[[
				Spidershot tear effect
				Azqswx
			--]]
			if player:HasCollectible(Items.spidershot_i) then
				if dmg_src.Type == EntityType.ENTITY_TEAR and dmg_src.Variant == 27 then
					local room = Game():GetRoom()
					local posE = entity.Position;
					index = room:GetGridIndex(posE);
					room:SpawnGridEntity(index,10,0,0,0)
					-- entity:AddEntityFlags(1<<7) -- <-- why permaSlow on the damaged enemy?
				end
			end
		end
	end
	return
end
_Stillbirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.mc_entity_take_dmg)

function _Stillbirth:TearLeaf_BossTimer()
	if tearLeaf_t then
		if Isaac.GetFrameCount() - tearLeaf_t >= 6*60 then
			tearLeaf_boss:ClearEntityFlags(1<<7)
			tearLeaf_t = nil
			tearLeaf_boss = nil
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.TearLeaf_BossTimer)
