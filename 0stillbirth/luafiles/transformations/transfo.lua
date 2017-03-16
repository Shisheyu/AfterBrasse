--[[
Item : transfo cricket
Type : transfo
By : Dogeek
Date : 2017-03-06
]]--


-----------------------------
-- USEFUL FUNCTIONS
-----------------------------

local function MakeBridge(grid, rock_index, player, room)
	local direction = player:GetHeadDirection()
	if direction == Direction.LEFT then
		direction = -1
	elseif direction == Direction.RIGHT then
		direction = 1
	elseif direction == Direction.UP then
		direction = -room:GetGridWidth()
	elseif direction == Direction.DOWN then
		direction = room:GetGridWidth()
	else
		direction = 0
	end
	if grid[rock_index+direction] then
		if grid[rock_index+direction].Desc.Type == GridEntityType.GRID_PIT then
			--local pit = grid[rock_index+direction]:ToPit()
			--room:TryMakeBridge(pit)
		end
	end
end

function _Stillbirth:transcricket_hasTransformUpdate()
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()
	local room = Game():GetRoom()
	local cricketPool = {4, 224, Items.cricketsPaw_i, Items.crickets_tail_i}--, Items.crickets_leash_i, Items.crickets_toys_i}
	if hasTransfo(cricketPool, 3) or g_vars.transcricket_hasTransfo then
        g_vars.transcricket_hasTransfo = true
        if not g_vars.transcricket_hasCostume then
        	player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/cricket.anm2"))
        	g_vars.transcricket_hasCostume = true
        end
		player:AddCacheFlags(CacheFlag.CACHE_FLYING)
		player:EvaluateItems()
		local grid = getGrid()
		for i=1, #grid do
			local gridEntity = grid[i]
			if gridEntity  then
				local type_ = gridEntity.Desc.Type
				if type_==GridEntityType.GRID_ROCK or type_==GridEntityType.GRID_ROCKB or type_==GridEntityType.GRID_ROCKT or type_==GridEntityType.GRID_ROCK_BOMB or type_==GridEntityType.GRID_ROCK_ALT or type_==GridEntityType.GRID_ROCK_SS or type_==GridEntityType.GRID_POOP then
                                        local scalar = math.abs(player:GetMovementVector():Normalized():Dot((player.Position - gridEntity.Position):Normalized()))
					if math.abs((player.Position - gridEntity.Position):Length()) <= 40  and (scalar>=0.8 and scalar <=1.2) then
						gridEntity:Destroy()
						--MakeBridge(grid, i, player, room)
					end
				end
			end
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.transcricket_hasTransformUpdate)

function _Stillbirth:transcricket_hasTransformDamage(entity, dmg_amount, dmg_flag, dmg_src, dmg_countdown)
	local player = Isaac.GetPlayer(0)
	local MaxSpiderSpawned = 40
        local roomType = Game():GetRoom():GetType()
	local cricketPool = {4, 224, Items.cricketsPaw_i, Items.crickets_tail_i}--, Items.crickets_leash_i, Items.crickets_toys_i}
	if hasTransfo(cricketPool, 3) or transcricket_hasTransfo then
        g_vars.transcricket_hasTransfo = true
		if (dmg_flag == DamageFlag.DAMAGE_SPIKES and roomType ~= RoomType.ROOM_SACRIFICE) or dmg_flag == DamageFlag.DAMAGE_POOP or dmg_flag == DamageFlag.DAMAGE_ACID then
			return false
		end
	end
	if player:GetNumBlueSpiders() and player:GetNumBlueSpiders() <= MaxSpiderSpawned then
		if hasTransfo(cricketPool, 3) and entity:IsVulnerableEnemy() and dmg_src.Type == 2 then
			player:AddBlueSpider(player.Position)
		end
	end
	return true
end
_Stillbirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.transcricket_hasTransformDamage);

function _Stillbirth:transcricket_hasTransformCache(player, cacheFlag)
    local player = Isaac.GetPlayer(0)
    local cricketPool = {4, 224, Items.cricketsPaw_i, Items.crickets_tail_i}--, Items.crickets_leash_i, Items.crickets_toys_i}
    if hasTransfo(cricketPool, 3) or transcricket_hasTransfo then
        g_vars.transcricket_hasTransfo = true
        if cacheFlag == CacheFlag.CACHE_FLYING then
            player.CanFly = false
        end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.transcricket_hasTransformCache)



--[[
Transfo L.A.S.E.R.
3 Items parmi : Tech 1 / Tech 2 / Tech.5 / Tech X / Robo Baby 1&2 / Tech 0

Effet : Tous les lasers possédés gagnent un effet supplémentaire qui peut changer de manière aléatoire à chaque tir et donc créer une rotation des effets. L’effet rouge est un bonus x1,5 damage sur le tir en question, le bonus bleu est homming shot et le bonus jaune paralyse les ennemis touchés.

--Dogeek
]]--
local laser_frozenEntities = {}

function _Stillbirth:LaserUpdate()
	local player = Isaac.GetPlayer(0)
	local blue = Color(0, 0, 0, 1, 0, 200, 255)
	local red = Color(0, 0, 0, 1, 140, 1, 1)
	local yellow = Color(0, 0, 0, 1, 243, 247, 2)
	local entities = Isaac.GetRoomEntities()
    local laserPool = {CollectibleType.COLLECTIBLE_TECHNOLOGY, CollectibleType.COLLECTIBLE_TECHNOLOGY_2, CollectibleType.COLLECTIBLE_TECH_5, CollectibleType.COLLECTIBLE_TECH_X, CollectibleType.COLLECTIBLE_ROBO_BABY, CollectibleType.COLLECTIBLE_ROBO_BABY_2, Items.tech0_i}
	if (hasTransfo(laserPool, 3) or g_vars.translaser_hasTransfo) then
		--[[for i=1, #entities do
			if entities[i]:IsActiveEnemy(false) and entities[i]:HasEntityFlags(1<<5) then
				if not has_value(laser_frozenEntities, entities[i]) then
					table.insert(laser_frozenEntities, entities[i])
				end
				for j=1, #laser_frozenEntities do
					if EntityRef(entities[i]) == EntityRef(laser_frozenEntities[j]) then
						if entities[i].FrameCount - laser_frozenEntities[j].FrameCount >= 75 then
							entities[i]:ClearEntityFlags(1<<5)
						end
					end
				end
			end
		end]]--
        g_vars.translaser_hasTransfo = true
        if not g_vars.translaser_hasCostume then
        	player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/laser.anm2"))
        	g_vars.translaser_hasCostume = true
        end
        if IsShooting(player) then
			local entities = Isaac.GetRoomEntities()
			for i=1, #entities do
				if entities[i].Type == EntityType.ENTITY_LASER and (entities[i].Parent.Type == EntityType.ENTITY_PLAYER or entities[i].Parent.Type == EntityType.ENTITY_FAMILIAR) then
					local laser = entities[i]:ToLaser()
					if not laser:HasEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH) then
						local rand = 2--math.random(1, 3)
						laser:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
						if rand == 1 then --Damage Up
							laser.CollisionDamage = laser.CollisionDamage * 1.5
							laser:SetColor(red, 60, 999, false, false)
						elseif rand == 2 then --paralysis
							--laser:AddFreeze(EntityRef(player), 180)--180 frames de freeze
							laser.TearFlags = 1<<5
							laser:SetColor(yellow, 60, 999, false, false)
						else --homing
							--laser:SetHomingType(0) --LaserHomingType Type ??
							--player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_SPOON_BENDER, false)
							laser.TearFlags = 1<<2 --homing tear flag
							laser:SetColor(blue, 60, 999, false, false)
						end
					end
				end
			end
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.LaserUpdate)
