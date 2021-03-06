pillColors = {}
pillEffects = {
				SPUP = Isaac.GetPillEffectByName("Shot Speed Up"),
				SPDN = Isaac.GetPillEffectByName("Shot Speed Down"),
				DMGUP = Isaac.GetPillEffectByName("Damage Up"),
				DMGDN = Isaac.GetPillEffectByName("Damage Down"),
				DISCHARGE = Isaac.GetPillEffectByName("Discharge !")
}

function _Stillbirth:AddPillsToPool()
	pillColors.SPUP = Isaac.AddPillEffectToPool(pillEffects.SPUP)
	pillColors.SPDN = Isaac.AddPillEffectToPool(pillEffects.SPDN)
	pillColors.DMGUP = Isaac.AddPillEffectToPool(pillEffects.DMGUP)
	pillColors.DMGDN = Isaac.AddPillEffectToPool(pillEffects.DMGDN)
	pillColors.DISCHARGE = Isaac.AddPillEffectToPool(pillEffects.DISCHARGE)
	--pillColors.MAP = Isaac.AddPillEffectToPool(Isaac.GetPillEffectByName("Morning After Pill"))
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, _Stillbirth.AddPillsToPool)


--shotspeed up

function _Stillbirth:shotSpeedUpPill(pillId)
	local player = Isaac.GetPlayer(0)
	if pillId == pillEffects.SPUP then
		player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
		g_vars.shot_speed_up_uses_counter = g_vars.shot_speed_up_uses_counter + 1
		player:EvaluateItems()
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_USE_PILL, _Stillbirth.shotSpeedUpPill, pillEffects.SPUP)

function _Stillbirth:shotSpeedUpCache(player, cacheFlag)
	if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed + 0.2*g_vars.shot_speed_up_uses_counter
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.shotSpeedUpCache, Isaac.GetPlayer(0))

--shotspeed dwn

function _Stillbirth:shotSpeedDownPill(pillId)
	local player = Isaac.GetPlayer(0)
	if pillId == pillEffects.SPDN then
		player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
		g_vars.shot_speed_dwn_uses_counter = g_vars.shot_speed_dwn_uses_counter + 1
		player:EvaluateItems()
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_USE_PILL, _Stillbirth.shotSpeedDownPill, pillEffects.SPDWN)

function _Stillbirth:shotSpeedDownCache(player, cacheFlag)
	if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed - 0.2*g_vars.shot_speed_dwn_uses_counter
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.shotSpeedDownCache, Isaac.GetPlayer(0))

--damage up

function _Stillbirth:damageUpPill(pillId)
	local player = Isaac.GetPlayer(0)
	if pillId == pillEffects.DMGUP then
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		if g_vars.damage_up_uses_counter < 6 then
			g_vars.damage_up_uses_counter = g_vars.damage_up_uses_counter + 1
		else
			g_vars.damage_down_uses_counter = g_vars.damage_down_uses_counter + 1
		end
		player:EvaluateItems()
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_USE_PILL, _Stillbirth.damageUpPill, pillEffects.DMGUP)

function _Stillbirth:damageUpCache(player, cacheFlag)
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + 0.5*g_vars.damage_up_uses_counter
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.damageUpCache, Isaac.GetPlayer(0))

--damage down

function _Stillbirth:damageDownPill(pillId)
	local player = Isaac.GetPlayer(0)
	if pillId == pillEffects.DMGDN then
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		g_vars.damage_down_uses_counter = g_vars.damage_down_uses_counter + 1
		player:EvaluateItems()
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_USE_PILL, _Stillbirth.damageDownPill, pillEffects.DMGDWN)

function _Stillbirth:damageDownCache(player, cacheFlag)
	if cacheFlag == CacheFlag.CACHE_DAMAGE and (player.Damage - 0.5*g_vars.damage_down_uses_counter) > 1 then
		player.Damage = player.Damage - 0.5*g_vars.damage_down_uses_counter
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.damageDownCache, Isaac.GetPlayer(0))

--discharge

function _Stillbirth:dischargePill(pillId)
	local player = Isaac.GetPlayer(0)
	if pillId == pillEffects.DISCHARGE then
		player:DischargeActiveItem()
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_USE_PILL, _Stillbirth.dischargePill, pillEffects.DISCHARGE)

--[[
--remove last pill
local usedPills = {}
function afterbrasse:trackUsedPills(pillId)
	table.insert(usedPills, pillId)
end

for i=1, PillEffect.NUM_PILL_EFFECTS do
	afterbrasse:AddCallback(ModCallbacks.MC_USE_PILL, afterbrasse.trackUsedPills, i)
end

function afterbrasse:removeLastPillPill(pillId)
	if usedPills[#usedPills] ~= pillId then
		local pill = usedPills[#usedPills]
		if pill == PillEffect.PILLEFFECT_FULL_HEALTH then
			player:TakeDamage(2)
		elseif pill == PillEffect.PILLEFFECT_BOMBS_ARE_KEYS then
			player:UsePill(pill, PillColor.PILL_NULL)
		elseif pill == PillEffect.PILLEFFECT_HEALTH_DOWN then
			player:UsePill(PillEffect.PILLEFFECT_HEALTH_UP, PillColor.PILL_NULL)
		elseif pill == PillEffect.PILLEFFECT_HEALTH_UP then
			player:UsePill(PillEffect.PILLEFFECT_HEALTH_DOWN, PillColor.PILL_NULL)
		elseif pill == PillEffect.PILLEFFECT_PRETTY_FLY then
			local once = false
			local entities = Isaac.GetRoomEntities()
			for i=1, #entities do
				if entities[i].Type == EntityType.ENTITY_FAMILIAR and entities[i].Variant == FamiliarVariant.FLY_ORBITAL and entities[i].Parent.Type == EntityType.ENTITY_PLAYER and not once then
					entities[i]:Remove()
					once = true
				end
			end
		elseif pill == PillEffect.PILLEFFECT_RANGE_DOWN then
			player:UsePill(PillEffect.PILLEFFECT_RANGE_UP, PillColor.PILL_NULL)
		elseif pill == PillEffect.PILLEFFECT_RANGE_UP then
			player:UsePill(PillEffect.PILLEFFECT_RANGE_DOWN, PillColor.PILL_NULL)
		elseif pill == PillEffect.PILLEFFECT_SPEED_DOWN then
			player:UsePill(PillEffect.PILLEFFECT_SPEED_UP, PillColor.PILL_NULL)
		elseif pill == PillEffect.PILLEFFECT_SPEED_UP then
			player:UsePill(PillEffect.PILLEFFECT_SPEED_DOWN, PillColor.PILL_NULL)
		elseif pill == PillEffect.PILLEFFECT_TEARS_DOWN then
			player:UsePill(PillEffect.PILLEFFECT_TEARS_UP, PillColor.PILL_NULL)
		elseif pill == PillEffect.PILLEFFECT_TEARS_UP then
			player:UsePill(PillEffect.PILLEFFECT_TEARS_DOWN, PillColor.PILL_NULL)
		elseif pill == PillEffect.PILLEFFECT_LUCK_DOWN then
			player:UsePill(PillEffect.PILLEFFECT_LUCK_UP, PillColor.PILL_NULL)
		elseif pill == PillEffect.PILLEFFECT_LUCK_UP then
			player:UsePill(PillEffect.PILLEFFECT_LUCK_DOWN, PillColor.PILL_NULL)
		elseif pill == PillEffect.PILLEFFECT_LARGER then
			player:UsePill(PillEffect.PILLEFFECT_SMALLER, PillColor.PILL_NULL)
		elseif pill == PillEffect.PILLEFFECT_SMALLER then
			player:UsePill(PillEffect.PILLEFFECT_LARGER, PillColor.PILL_NULL)
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_USE_PILL, _Stillbirth.shotSpeedUpPill, Isaac.GetPillEffectByName("Morning After Pill"))
]]--
