
local function Stillbirth_Player_Init() -- player ini
	local player = Isaac.GetPlayer(0)
	if not g_vars then
		g_vars = data_Init()
	end
	REBALANCE_InitKeeper()
	--force evaluation of every cacheFlags
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
	player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
	player:AddCacheFlags(CacheFlag.CACHE_LUCK)
	player:AddCacheFlags(CacheFlag.CACHE_SPEED)
	player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
	player:AddCacheFlags(CacheFlag.CACHE_FLYING)
	player:AddCacheFlags(CacheFlag.CACHE_TEARCOLOR)
	player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
	player:AddCacheFlags(CacheFlag.CACHE_WEAPON)
	player:AddCacheFlags(CacheFlag.CACHE_ALL)
	player:EvaluateItems()
--~ 	db_z = "RESET"
end
--~ _Stillbirth:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,_Stillbirth.Stillbirth_VarsInit) -- NOP

local function IsFamiliarExists(FamVariant)
	local entities = Isaac.GetRoomEntities()
	for i=1, #entities do
		if entities[i].Type == 3 and entities[i].Variant == FamVariant then -- 3 = familiar flag
			return true
		end
	end
	return false
end

-- FamiliarProtectedSpawn & proper player init
function _Stillbirth:FamiliarProtectedSpawn()
    local player = Isaac.GetPlayer(0)
	if player.FrameCount  == 1 then
		Stillbirth_Player_Init()
	elseif player.FrameCount == 5 then -- Anti Multi familiar spawn at game restart: May still have some use
		if g_vars.GlobalSeed == 0 then
			SetRandomSeed()
		end
		Isaac.DebugString(tostring(g_vars.GlobalSeed))
			--g_vars.legacy_spawned = IsFamiliarExists(Familiar.legacy_variant)
			g_vars.FAM_SunWukongExists = IsFamiliarExists(Familiars.SunWukong_Familiar_Variant)
			g_vars.FAM_BombBumExists = IsFamiliarExists(Familiars.FAM_BombBumFamiliarVariant)
			Isaac.DebugString("Multi familiar Protection")
    else
--[[
		if not g_vars.legacy_spawned and player:HasCollectible(Items.legacy_i) then -- Legacy
			local e = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, Familiar.legacy_variant, 0, player.Position, Vector(0, 0), player);
			e = e:GetSprite()
			e:Play("Float", true)
			g_vars.legacy_spawned = true;
		end
--]]
--[[
		if not g_vars.hasElectronSpawned and player:HasCollectible(Items.electron_i) then -- Electron
			Isaac.Spawn(Familiars.electronFamiliar, Familiars.electronFamiliarVariant, 0, player.Position, Vector(0, 0), player)
			g_vars.numberOfElectrons = g_vars.numberOfElectrons + 1
			g_vars.hasElectronSpawned = true
		end
--]]
		if not g_vars.FAM_BombBumExists and player:HasCollectible(Items.FAM_BombBum_i) then -- BombBum
			local e = Isaac.Spawn(Familiars.FAM_BombBumFamiliar, Familiars.FAM_BombBumFamiliarVariant, 0, player.Position, Vector(0, 0), player)
			e:AddEntityFlags(1<<21) -- FLAG_DONT_OVERWRITE
			g_vars.FAM_BombBumExists = true
		end
--~ 		if not g_vars.FAM_LastRNGBabyExists and player:HasCollectible(Items.rngbaby_i) then -- RNGBaby
--~ 			local rand = (math.random(seed) % #AtkfamiliarPool) + 1
--~ 			local e = Isaac.Spawn(3, AtkfamiliarPool[rand], 0, player.Position, Vector(0, 0), player)
--~ 			e:AddEntityFlags(1<<21) -- FLAG_DONT_OVERWRITE
--~ 			g_vars.FAM_RNGBabyExists = true
--~ 		end
		if not g_vars.FAM_SunWukongExists  and player:HasCollectible(Items.SunWukong_i) then -- SunWukong
			local e = Isaac.Spawn(3, Familiars.SunWukong_Familiar_Variant, 0, player.Position, Vector(0, 0), player)
			e:AddEntityFlags(1<<21) -- FLAG_DONT_OVERWRITE
			g_vars.FAM_SunWukongExists = true
		end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.FamiliarProtectedSpawn)
