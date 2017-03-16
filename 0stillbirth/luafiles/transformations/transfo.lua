--[[
Item : transfo cricket
Type : transfo
By : Dogeek
Date : 2017-03-06
TODO : MakeBridge fix
]]--


local cricketPool = {4, 224, Items.cricketsPaw_i, Items.crickets_tail_i}--, Items.crickets_leash_i, Items.crickets_toys_i}

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
	if g_vars.transcricket_hasTransfo then
		if (dmg_flag == DamageFlag.DAMAGE_SPIKES and roomType ~= RoomType.ROOM_SACRIFICE) or dmg_flag == DamageFlag.DAMAGE_POOP or dmg_flag == DamageFlag.DAMAGE_ACID then
			return false
		end
	end
	if player:GetNumBlueSpiders() and player:GetNumBlueSpiders() <= MaxSpiderSpawned then
		if g_vars.transcricket_hasTransfo and entity:IsVulnerableEnemy() and dmg_src.Type == 2 then
			player:AddBlueSpider(player.Position)
		end
	end
	return true
end
_Stillbirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.transcricket_hasTransformDamage);

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


function _Stillbirth:LaserUpdate()
	local player = Isaac.GetPlayer(0)
	local blue = Color(0, 0, 0, 1, 0, 200, 255)
	local red = Color(0, 0, 0, 1, 140, 1, 1)
	local yellow = Color(0, 0, 0, 1, 243, 247, 2)
	local entities = Isaac.GetRoomEntities()
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


--[[Transfo Zodiac
Nagachi
Dogeek

TODO : Taurus & Gemini
]]--
--[[
local zodiacPool = {299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 318}
 
function _Stillbirth:initPlayer(player)
 
  spawn = false;
 
  -- Taurus
  addSpeedTaurus = 0;
  speedAdded = 0;
  invicibilityUp = false;
  invicibilityOver = false;
  frameAccount = 0;
 
  -- Aries
  hasSpeedAries = false;
  isInitEntities = false;
end
 
_Stillbirth:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,_Stillbirth.initPlayer);


function transfoSound()
	-- Transformation sound
	local sound_entity = Isaac.Spawn(EntityType.ENTITY_FLY, 0, 0, Vector(0,0), Vector(0,0), nil):ToNPC(); -- HACK: The only way to play a sound is through a NPC so we craft a entity that we remove right away
	sound_entity:PlaySound(SoundEffect.SOUND_POWERUP_SPEWER, 1, 0, false, 1);
	sound_entity:Remove();
end
 
-- Aquarius effects
function _Stillbirth:aquarius_effect()
	local player = Isaac.GetPlayer(0);
	local entities = Isaac.GetRoomEntities()
	if HasTransfo(zodiacPool, 4) and player:HasCollectible(aquarius) then
		local creepPos = {}
		for i=1, #entities do
			if entities[i].Type == 1000 and entities[i].Variant == EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL then
				table.insert(creepPos, entities[i].Position)
			end
		end
		for i=1, #entities do
			for j=1, #creepPos do
				if entities[i]:IsActiveEnemy() and getDistance(entities[i].Position, creepPos[j]) <= 32 then
					rand = math.random(-10, 20)
					if rand<= player.Luck then
						Isaac.Spawn(1000, EffectVariant.CRACK_THE_SKY, 0, entities[i].Position, Vector(0,0), player)
						entities[i]:TakeDamage(player.Damage+20, DamageFlag.DAMAGE_LASER, EntityRef(player), 0)
					end
				end
			end
		end
	end
end
 
-- Pisces's effects
function _Stillbirth:pisces_effect_addCacheFlag()
  local player = Isaac.GetPlayer(0);
  if HasTransfo(zodiacPool, 4) and player:HasCollectible(CollectibleType.COLLECTIBLE_PISCES) then
    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY);
    player:EvaluateItems();
  end
end
 
function _Stillbirth:pisces_effect_updateStat(player, cacheFlag)
  local player = Isaac.GetPlayer(0);
  if HasTransfo(zodiacPool, 4) and player:HasCollectible(CollectibleType.COLLECTIBLE_PISCES) and cacheFlag == CacheFlag.CACHE_FIREDELAY then
    player.MaxFireDelay = player.MaxFireDelay - 1;
  end
end
 
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.pisces_effect_addCacheFlag);
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.pisces_effect_updateStat);
 
--Capricorn's effect
function _Stillbirth:capricorn_effect_addCacheFlag()
  local player = Isaac.GetPlayer(0);
  if HasTransfo(zodiacPool, 4) and player:HasCollectible(CollectibleType.COLLECTIBLE_CAPRICORN) then
    player:AddCacheFlags(CacheFlag.CACHE_ALL);
    player:EvaluateItems();
  end
end

function _Stillbirth:capricorn_effect_cache(player, cacheFlag)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CAPRICORN)
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
end
-- Sagittarius effects (maybe need to balance the shotspeed down)
function _Stillbirth:sagittarius_effect_addCacheFlag()
  local player = Isaac.GetPlayer(0);
 
  if HasTransfo(zodiacPool, 4) and player:HasCollectible(CollectibleType.COLLECTIBLE_SAGITTARIUS) then
    player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED);
    player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG);
    player:EvaluateItems();
  end
end
 
function _Stillbirth:sagittarius_effect_updateStat(player, cacheFlag)
  local player = Isaac.GetPlayer(0);
  if HasTransfo(zodiacPool, 4) and player:HasCollectible(CollectibleType.COLLECTIBLE_SAGITTARIUS) then
    if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
      player.ShotSpeed = player.ShotSpeed - 0.1; -- to balance
    end
    if cacheFlag == CacheFlag.CACHE_TEARFLAG then
      player.TearFlags = player.TearFlags | 1; -- Add spectral tears
    end
  end
end
 
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.sagittarius_effect_addCacheFlag);
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.sagittarius_effect_updateStat);
 
-- Scorpio's effects
local poisoned_enemies = {}
function _Stillbirth:scorpio_effect()
    local player = Isaac.GetPlayer(0);
    local entities = Isaac.GetRoomEntities()
	if player:HasCollectible(CollectibleType.COLLECTIBLE_SCORPIO) and hasTransfo(zodiacPool, 4) then
		player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_VIRUS, false);
		for i=1, #poisoned_enemies do
			e = poisoned_enemies[i]
			if e:IsDead() then
				rand = math.random(-10, 20)
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
	end
end
 
 
-- Virgo's effect
function _Stillbirth:virgo_effect(player, cacheFlag)
    local player = Isaac.GetPlayer(0);
 
    if player:HasCollectible(CollectibleType.COLLECTIBLE_VIRGO) and HasTransfo(zodiacPool, 4) then
      player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_PHD, false);
    end
end
 
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.virgo_effect);
 
-- Gemini's effect
function _Stillbirth:gemini_effect(player, cacheFlag)
    local player = Isaac.GetPlayer(0);
end
 
 
-- WARNING : ONLY 1 CALLBACK ENTITY_TAKE_DMG in the file (if not, only the first one will works)
-- Leo + aries effects for now
function _Stillbirth:damageManager(entity, dmg_amount, dmg_flag, dmg_src, dmg_countdown)
  local player = Isaac.GetPlayer(0);
  local roomType = Game():GetRoom():GetType()
  local damageReturn = true;
 
  if HasTransfo(zodiacPool, 4) then
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LEO) then
      if ((dmg_flag == DamageFlag.DAMAGE_SPIKES and roomType ~= RoomType.ROOM_SACRIFICE) or dmg_flag == DamageFlag.DAMAGE_ACID) then
        damageReturn = false;
      end
    end
 
    if player:HasCollectible(CollectibleType.COLLECTIBLE_ARIES) then
      if dmg_flag == DamageFlag.DAMAGE_EXPLOSION or dmg_src.Type == EntityType.ENTITY_TEAR or player.MoveSpeed<1.7 then
        damageReturn = true;
      else
        damageReturn = false;
      end
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_GEMINI) then
    	--
    end
  end
  return damageReturn;
end
 
_Stillbirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.damageManager, EntityType.ENTITY_PLAYER);
 
 
-- Cancer's effect
function _Stillbirth:cancer_effect(player, cacheFlag)
    local player = Isaac.GetPlayer(0);
 
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CANCER) and HasTransfo(zodiacPool, 4) then
      player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER, false);
    end
end
 
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.cancer_effect);
 
 
-- Need to be fixed
-- Taurus effects
function _Stillbirth:taurus_effect_addCacheFlag(player)
    local player = Isaac.GetPlayer(0);
 
    if HasTransfo(zodiacPool, 4) and player:HasCollectible(CollectibleType.COLLECTIBLE_TAURUS) then
        if Isaac:GetFrameCount()%15 == 0 then
          addSpeedTaurus = addSpeedTaurus + 1;
          player:AddCacheFlags(CacheFlag.CACHE_SPEED);
          player:EvaluateItems();
        end
    end
end
 
function _Stillbirth:taurus_effect_updateStat(player, cacheFlag)
  local player = Isaac.GetPlayer(0);
  local room = Game():GetRoom();
 
  if HasTransfo(zodiacPool, 4) and player:HasCollectible(CollectibleType.COLLECTIBLE_TAURUS) and not room:IsClear() and
    cacheFlag == CacheFlag.CACHE_SPEED and player.MoveSpeed <= 1.9 then
 
    speedAdded = 0.065*addSpeedTaurus;
    player.MoveSpeed = player.MoveSpeed + speedAdded;
 
  elseif room:IsClear() then
    addSpeedTaurus = 0;
    speedAdded = 0;
    player.MoveSpeed = player.MoveSpeed - speedAdded;
    invicibilityUp = false;
    frameAccount = 0;
  end
end
 
function _Stillbirth:taurus_effect_updateInvincibility(player)
  local player = Isaac.GetPlayer(0);
  local room = Game():GetRoom();
 
  if player:HasCollectible(CollectibleType.COLLECTIBLE_TAURUS) and HasTransfo(zodiacPool, 4) and player.MoveSpeed >= 2.0 and
    not invicibilityUp then
 
    player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN, true);
    invicibilityUp = true;
    frameAccount = frameAccount + 1;
 
  elseif frameAccount > 200 then
    frameAccount = 0;
    invicibilityUp = false;
  end
 
end
 
function _Stillbirth:taurus_test(player)
  local player = Isaac.GetPlayer(0);
 
  if player:HasCollectible(CollectibleType.COLLECTIBLE_TAURUS) then
    frameAccount = frameAccount + 1;
  end
 
  if player:HasCollectible(CollectibleType.COLLECTIBLE_TAURUS) and frameAccount >= 500 and frameAccount <= 1000 then
    player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN, false);
 
  end
end
 
-- _Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.taurus_effect_addCacheFlag);
-- _Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.taurus_effect_updateStat);
-- _Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.taurus_effect_updateInvincibility);
 
_Stillbirth:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, _Stillbirth.taurus_test);
 
-- Need to balance it probably
-- Libra's effect
function _Stillbirth:libra_effect_addCacheFlag()
  local player = Isaac.GetPlayer(0);
 
  if HasTransfo(zodiacPool, 4) and player:HasCollectible(CollectibleType.COLLECTIBLE_LIBRA) then
    player:AddCacheFlags(CacheFlag.CACHE_LUCK);
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
    player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED);
    player:AddCacheFlags(CacheFlag.CACHE_SPEED);
    player:AddCacheFlags(CacheFlag.CACHE_RANGE);
    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY);
    player:EvaluateItems();
  end
end
 
function _Stillbirth:libra_effect_updateStat(player, cacheFlag)
  local player = Isaac.GetPlayer(0);
 
  if HasTransfo(zodiacPool, 4) and player:HasCollectible(CollectibleType.COLLECTIBLE_LIBRA) then
    if cacheFlag == CacheFlag.CACHE_SPEED then
      player.MoveSpeed = player.MoveSpeed * 1.25;
    end
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage * 1.25;
    end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = player.MaxFireDelay * 1.25;
    end
    if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed * 1.25;
    end
    if cacheFlag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed * 1.25;
    end
    if cacheFlag == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck * 1.25;
    end
    if cacheFlag == CacheFlag.CACHE_RANGE then
        player.TearHeight = player.TearHeight + 10;
    end
    if cacheFlag == CacheFlag.CACHE_RANGE then
        player.TearFallingSpeed = player.TearFallingSpeed + 0.5;  
    end
  end
end
 
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.libra_effect_addCacheFlag);
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.libra_effect_updateStat);]]--
