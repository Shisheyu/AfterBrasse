local bandals_transfals = {
						ZODIAC = Sprite(),
						MAX = Sprite(),
						LASER = Sprite(),
						BUBBLES = Sprite()
						}

bandals_transfals.ZODIAC:Load("gfx/ui/tansformations/ui_transformation_zodiac.anm2", true)
bandals_transfals.MAX:Load("gfx/ui/tansformations/ui_transformation_max.anm2", true)
bandals_transfals.LASER:Load("gfx/ui/tansformations/ui_transformation_laser.anm2", true)
bandals_transfals.BUBBLES:Load("gfx/ui/tansformations/ui_transformation_bubbles.anm2", true)

--[[
Item : transfo cricket
Type : transfo
By : Dogeek
Date : 2017-03-06
]]--


local cricketPool = {4, 224, Items.cricketsPaw_i, Items.crickets_tail_i}--, Items.crickets_leash_i, Items.crickets_toys_i}

local function MakeBridge(rock_index)
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local i = getGridIndex(player:GetHeadDirection(), rock_index)
	local ent = room:GetGridEntity(i)
	if ent and ent.Desc.Type == GridEntityType.GRID_PIT then
        room:TryMakeBridge(ent)
    end
end

function _Stillbirth:transcricket_hasTransformUpdate()
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()
	local room = Game():GetRoom()
	if hasTransfo(cricketPool, 3) or g_vars.transcricket_hasTransfo then
        g_vars.transcricket_hasTransfo = true
        if not g_vars.transcricket_hasCostume then
        	player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/cricket.anm2"))
        	SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER, 1, 0, false, 1)
        	bandals_transfals.MAX:Play("Text", true)
        	g_vars.transcricket_hasCostume = true
        end
		player:AddCacheFlags(CacheFlag.CACHE_FLYING)
		player:EvaluateItems()
		local grid = room:GetGridSize()-1
		for i=1, grid do
			local gridEntity = room:GetGridEntity(i)
			if gridEntity  then
				local type_ = gridEntity.Desc.Type
				if type_==GridEntityType.GRID_ROCK or type_==GridEntityType.GRID_ROCKB or type_==GridEntityType.GRID_ROCKT or type_==GridEntityType.GRID_ROCK_BOMB or type_==GridEntityType.GRID_ROCK_ALT or type_==GridEntityType.GRID_ROCK_SS or type_==GridEntityType.GRID_POOP then
					if isColinear(player.Position, gridEntity.Position, 0.2) and getDistance(player.Position, gridEntity.Position) <= 40 then
						MakeBridge(gridEntity:GetGridIndex())
						gridEntity:Destroy()
					end
				end
			end
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.transcricket_hasTransformUpdate)

function _Stillbirth:transcricket_hasTransformCache(player, cacheFlag)
    local player = Isaac.GetPlayer(0)
    if g_vars.transcricket_hasTransfo then
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

TODO : stop randomizing every frame (random every 3-4 secs) & fix paralysis
--Dogeek
]]--
local laser_frozenEntities = {}
local laserPool = {CollectibleType.COLLECTIBLE_TECHNOLOGY, CollectibleType.COLLECTIBLE_TECHNOLOGY_2, CollectibleType.COLLECTIBLE_TECH_5, CollectibleType.COLLECTIBLE_TECH_X, CollectibleType.COLLECTIBLE_ROBO_BABY, CollectibleType.COLLECTIBLE_ROBO_BABY_2, Items.tech0_i}

local random_laser_effect = 1

function LaserFreeze(laser)
	local entities = Isaac.GetRoomEntities()
	local player = Isaac.GetPlayer(0)
	for i=1, #entities do
		if entities[i]:IsActiveEnemy() then
			local e = entities[i]
			local laser_endpoint = laser:GetEndPoint()
			if isColinear(e.Position-player.Position, laser_endpoint-player.Position, 0.04) then
				e:AddFreeze(EntityRef(player), 300) --add freeze for 300 frames
			end
		end
	end
end

function _Stillbirth:LaserUpdate()
	local player = Isaac.GetPlayer(0)
	local blue = Color(0, 0, 0, 1, 0, 200, 255)
	local red = Color(0, 0, 0, 1, 140, 1, 1)
	local yellow = Color(0, 0, 0, 1, 243, 247, 2)
	local entities = Isaac.GetRoomEntities()
	if Game():GetFrameCount() % 60 == 0 then random_laser_effect = math.random(1,3) end
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
        	SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER, 1, 0, false, 1) 
        	player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/laser.anm2"))
        	bandals_transfals.LASER:Play("Text", true)
        	g_vars.translaser_hasCostume = true
        end
        if IsShooting(player) then
			local entities = Isaac.GetRoomEntities()
			for i=1, #entities do
				if entities[i].Type == EntityType.ENTITY_LASER and (entities[i].Parent.Type == EntityType.ENTITY_PLAYER or entities[i].Parent.Type == EntityType.ENTITY_FAMILIAR) then
					local laser = entities[i]:ToLaser()
					if not laser:HasEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH) then
						if Game():GetFrameCount() % 30 == 0 then rand = math.random(1, 3) end
						laser:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
						if random_laser_effect == 1 then --Damage Up
							laser.CollisionDamage = laser.CollisionDamage * 1.5
							laser:SetColor(red, 60, 999, false, false)
						elseif random_laser_effect == 2 then --paralysis
							--laser:AddFreeze(EntityRef(player), 180)--180 frames de freeze
							--laser.TearFlags = bit.bor(laser.TearFlags, 32)
							LaserFreeze(laser)
							laser:SetColor(yellow, 60, 999, false, false)
						else --homing
							laser.TearFlags = bit.bor(laser.TearFlags, 4) --homing tear flag
							laser:SetColor(blue, 60, 999, false, false)
						end
					end
				end
			end
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.LaserUpdate)
--[[
Transfo Bubbles

Sliost & Dogeek & krayz(for leaf tears and code to shoot them)
]]--

--local uiStreak = Sprite()
--uiStreak:Load("gfx/ui/ui_transformation_bubbles.anm2",true) -- Preloading the sprite used for the transformation name animation (in order not to load it every frame)

--DISABLED TRANSFORMATION UNTIL A FIX FOR THE CRASH IS FOUND

function bubbles_lerp(a, b, t)
    return a + (b - a) * (math.atan(t*0.19467)/2 + 1)
end

function BubblesJumpAnimation()
  local player = Isaac.GetPlayer(0)
  if timer ~= nil and bubbles_transfo then
    if timer < 9 then
        player.Position = bubbles_lerp(player.Position, landingVector,timer)
        timer = timer + 1 
    else

      player.ControlsEnabled = true
    end
  end
end

function _Stillbirth:BubblesBehavior()
	local player = Isaac.GetPlayer(0)
	local level = Game():GetLevel()
	local room = level:GetCurrentRoom()
	local direction = player:GetMovementDirection()
	local pos = player.Position 
	local idx = room:GetGridIndex(pos)
	local nextGridEntity = -1
	local landing = 0
	local bubblesPool = {Items.mizaru_i, Items.kikazaru_i, Items.iwazaru_i, Items.golden_idol_i, Items.ExBanana_i, Items.SunWukong_i, Items.BubblesHead_i}
	local bubbles_transfo = hasTransfo(bubblesPool, 3)

    -----------------------------------
    -- Bubbles transformation behavior
    -----------------------------------
	if bubbles_transfo then
      -- Transform if available
      	if not g_vars.bubblesCostume then
      		g_vars.bubblesCostume = true
      		SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER, 1, 0, false, 1)
      		bandals_transfals.BUBBLES:Play("Text", true)
      		player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/transformation_bubbles.anm2"))
      	end
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:AddCacheFlags(CacheFlag.CACHE_SPEED)
		player:EvaluateItems()
        if IsShooting( player ) and player.FrameCount%player.MaxFireDelay == 0 then--rework because that glitches
            local v = Vector( math.abs( player:GetLastDirection().X ), math.abs( player:GetLastDirection().Y ) )
            if ( v.X == 1 or v.X == 0 ) and ( v.Y == 1 or v.Y == 0 ) then
                local tear = GetClosestTear( entities, player, 2, CustomEntities.TearLeaf_Variant )
                local vel = Vector(7.5*player.ShotSpeed,7.5*player.ShotSpeed)
                if tear then
                    vel = tear.Velocity
                    tear:Remove()
                end
                ShootCustomTear( CustomEntities.TearLeaf_Variant, player, player, 1.0, vel:__mul(1.2), true )
            end
		end
      -- Can jump over pit -------code currently crashes the game
		--[[
		if direction == 0 and math.abs(player.Velocity.X) < 1 then
			nextGridEntity = idx - 1
			landing = idx - 2
		elseif direction == 1 and math.abs(player.Velocity.Y) < 1 then
			nextGridEntity = idx - 15
			landing = idx - 30
		elseif direction == 2 and math.abs(player.Velocity.X) < 1 then
			nextGridEntity = idx + 1
			landing = idx + 2
		elseif direction == 3 and math.abs(player.Velocity.Y) < 1 then
			nextGridEntity = idx + 15
			landing = idx + 30
		else
			nextGridEntity = -1
		end
		if nextGridEntity ~= -1 then
			local gridEntity = room:GetGridEntity(nextGridEntity)
			local landingGridEntity = room:GetGridEntity(landing)
			if gridEntity ~= nil then
				local toPit = gridEntity:ToPit()
				if toPit ~= nil and landingGridEntity == nil then -- Waiting for GetType() to work

					landingVector = room:GetGridPosition(landing)

					timer = -8

					player.ControlsEnabled = false

					player:PlayExtraAnimation("Jump")

				end

			end

		end]]--
	end
end



--_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.BubblesBehavior);

function _Stillbirth:BubblesCache(player, cacheFlag)
	local player = Isaac.GetPlayer(0)
	local bubblesPool = {Items.mizaru_i, Items.kikazaru_i, Items.iwazaru_i, Items.golden_idol_i, Items.ExBanana_i, Items.SunWukong_i, Items.BubblesHead_i}
	local bubbles_transfo = hasTransfo(bubblesPool, 3)
	if bubbles_transfo then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + 0.3
		end
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 2.5
		end
	end
end
--_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.BubblesCache);

--[[Transfo Zodiac
Nagachi
Dogeek

TODO : Taurus & Gemini
]]--

local zodiacPool = {299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 318, 392}
-- Taurus
taurusEffectGiven = false
taurusSpeed = 0
invincibilityFrameCounter = 0
-- Aries
local hasSpeedAries = false
local isInitEntities = false
-- Scorpio
local poisoned_enemies = {}
-- Gemini
local gemini_unleashed_has_spawned = false
local gemini_unleashed_fam = nil

function _Stillbirth:initZodiacPlayer(player)
	-- Taurus
	taurusEffectGiven = false
	taurusSpeed = 0
	invincibilityFrameCounter = 0
	-- Aries
	hasSpeedAries = false
	isInitEntities = false
	-- Scorpio
	poisoned_enemies = {}
	--Gemini
	gemini_unleashed_has_spawned = false
	gemini_unleashed_fam = nil
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,_Stillbirth.initZodiacPlayer);

function _Stillbirth:ZodiacTransfoUpdate()
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()
	local room = Game():GetRoom()
	local framecount = Game():GetFrameCount()
	if hasTransfo(zodiacPool, 3) then
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		if not g_vars.zodiacTransformed then
			player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/zodiac_transfo.anm2"))
			player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/zodiac_aura.anm2"))
			player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/zodiac_eyeshoot.anm2"))
			bandals_transfals.ZODIAC:Play("Text", true)
			SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER, 1, 0, false, 1) 
			g_vars.zodiacTransformed = true
		end
		if player:HasCollectible(308) then --aquarius
			local creepPos = {}
			for i=1, #entities do
				if entities[i].Type == 1000 and entities[i].Variant == EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL then
					table.insert(creepPos, entities[i].Position)
				end
			end
			for i=1, #entities do
				for j=1, #creepPos do
					if entities[i]:IsActiveEnemy() and getDistance(entities[i].Position, creepPos[j]) <= 20 then --adjust the distance ??
						local rand = math.random(-10, 40)
						if rand<= player.Luck then
							Isaac.Spawn(1000, EffectVariant.CRACK_THE_SKY, 0, entities[i].Position, Vector(0,0), player)
							entities[i]:TakeDamage(player.Damage+20, DamageFlag.DAMAGE_LASER, EntityRef(player), 0)
						end
					end
				end
			end
		end --end aquarius
		if player:HasCollectible(309) or player:HasCollectible(307) or player:HasCollectible(306) or player:HasCollectible(304) then --pisces&capricorn&sagittarius&Libra
			player:EvaluateItems()
		end --end evaluate items
		if player:HasCollectible(305) then --scorpio
			player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_VIRUS, false);
			for i=1, #poisoned_enemies do
				e = poisoned_enemies[i]
				if e:IsDead() then
					local rand = math.random(-10, 40)
					if rand < player.Luck then
						Isaac.Spawn(5, 10, 6, e.Position, Vector(0,0), player)
					end
				end
			end
			poisoned_enemies = {}
			for i=1, #entities do
				local e = entities[i]
				if e:IsActiveEnemy() and e:HasEntityFlags(1<<6) then
					table.insert(poisoned_enemies, e)
				end
			end
		end --end scorpio
		if player:HasCollectible(303) then --virgo
			player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_PHD, false);
		end --end virgo
		if player:HasCollectible(301) then --cancer
			player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER, false);
		end --end cancer
		if player:HasCollectible(CollectibleType.COLLECTIBLE_TAURUS) then --taurus effect
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)
			if framecount%3 == 0 and player.MoveSpeed + taurusSpeed < 2.0 and not taurusEffectGiven and not room:IsClear() then -- every 3 frames gives a bit more speed
				taurusSpeed = taurusSpeed + 0.01
			end
			if player.MoveSpeed + taurusSpeed >= 2.0 then
				invincibilityFrameCounter = invincibilityFrameCounter + 1
			end
			if invincibilityFrameCounter > 0 and not taurusEffectGiven then
				player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN, false)
				taurusEffectGiven = true
			end
			if invincibilityFrameCounter >= 150 or isRoomOver(room) then
				player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN)
				invincibilityFrameCounter = 0
				taurusSpeed = 0
			end
			player:EvaluateItems()
		end -- end taurus
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.ZodiacTransfoUpdate)

function _Stillbirth:ZodiacTransfoCache(player, cacheFlag)
	local player = Isaac.GetPlayer(0)
	if g_vars.zodiacTransformed then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_PISCES) and cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay - 1
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_CAPRICORN) and cacheFlag == CacheFlag.CACHE_ALL then --a recoder pour donner qu'une fois
			local cmp = {}
			cmp.dmg = player.Damage / 3.5
			cmp.rng = -player.TearHeight / 23.75
			cmp.fd = 10/player.MaxFireDelay
			cmp.spd = player.MoveSpeed
			cmp.st = player.ShotSpeed
			cmp.lck = player.Luck
			if cmp.lck < math.min(cmp.dmg, cmp.rng, cmp.fd, cmp.spd, cmp.st) then
				player.Luck = player.Luck + 1
			elseif cmp.st < math.min(cmp.dmg, cmp.rng, cmp.fd, cmp.spd, cmp.lck) then
				player.ShotSpeed = player.ShotSpeed + 0.4
			elseif cmp.spd < math.min(cmp.dmg, cmp.rng, cmp.fd, cmp.st, cmp.lck) then
				player.MoveSpeed = player.MoveSpeed + 0.3
			elseif cmp.fd < math.min(cmp.dmg, cmp.rng, cmp.spd, cmp.st, cmp.lck) then
				player.MaxFireDelay = player.MaxFireDelay - 2
			elseif cmp.rng < math.min(cmp.dmg, cmp.fd, cmp.spd, cmp.st, cmp.lck) then
				player.TearHeight = player.TearHeight - 5
			elseif cmp.dmg < math.min(cmp.rng, cmp.fd, cmp.spd, cmp.st, cmp.lck) then
				player.Damage = player.Damage + 1
			else
				player.Luck = player.Luck + 1
				player.ShotSpeed = player.ShotSpeed + 0.1
				player.MoveSpeed = player.MoveSpeed + 0.1
				player.MaxFireDelay = player.MaxFireDelay - 1
				player.TearHeight = player.TearHeight - 2
				player.Damage = player.Damage + 0.3
			end
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_SAGITTARIUS) then
			if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
				player.ShotSpeed = player.ShotSpeed - 0.1; -- to balance
			end
			if cacheFlag == CacheFlag.CACHE_TEARFLAG then
				player.TearFlags = player.TearFlags | 1; -- Add spectral tears
			end
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_LIBRA) then
			if cacheFlag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed * 1.25;
			end
			if cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage * 1.25;
			end
			if cacheFlag == CacheFlag.CACHE_FIREDELAY then
				player.MaxFireDelay = math.floor(player.MaxFireDelay * 0.75)
			end
			if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
				player.ShotSpeed = player.ShotSpeed * 1.25;
			end
			if cacheFlag == CacheFlag.CACHE_LUCK then
				player.Luck = player.Luck * 1.25;
			end
			if cacheFlag == CacheFlag.CACHE_RANGE then
				player.TearHeight = player.TearHeight * 1.25;
			end
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_TAURUS) then
			if cacheFlag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed + taurusSpeed
			end
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.ZodiacTransfoCache)

function _Stillbirth:ZodiacNewRoomUpdate()
	local player = Isaac.GetPlayer(0)
	-- Taurus
	taurusEffectGiven = false
	taurusSpeed = 0
	invincibilityFrameCounter = 0
	-- Gemini
	if zodiacTransformed then
		if gemini_unleashed_has_spawned then
			gemini_unleashed_has_spawned = false
			gemini_unleashed_fam:Remove()
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_GEMINI) then
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_GEMINI)
			player:AddCollectible(CollectibleType.COLLECTIBLE_GEMINI, 0, false)
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, _Stillbirth.ZodiacNewRoomUpdate)