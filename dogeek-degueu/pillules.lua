--[[
Item : Pills
Type : Dmg up/dn, Shotspeed up/dn, discharge spacebar, cancel last pill, 
By : Dogeek
Date : 2017-03-07
]]--

local afterbrasse = RegisterMod("AfterBrasse", 1)

-----------------------------
-- USEFUL FUNCTIONS
-----------------------------

local function IsShooting(player)
	if player:GetFireDirection() == -1 then
		return false
	else
		return true
	end
end

function print(...)
	local str, sep = "", ""
	for i=1, select('#', ...) do
		str = str .. sep .. tostring(select(i, ...))
		sep = '\t'
	end
	return Isaac.DebugString(str)
end

function has_value (tab, val)
	for index, value in ipairs (tab) do
		if value == val then
			return true
		end
	end
	return false
end
--CODE


function afterbrasse:InitVariable(player)

end

afterbrasse:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,afterbrasse.InitVariable)

--shotspeed up
local shot_speed_up_uses_counter = 0

function afterbrasse:shotSpeedUpPill(pillId)
	local player = Isaac.GetPlayer(0)
	player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
	shot_speed_up_uses_counter = shot_speed_up_uses_counter + 1
	player:EvaluateItems()
end
afterbrasse:AddCallback(ModCallbacks.MC_USE_PILL, afterbrasse.shotSpeedUpPill, Isaac.GetPillEffectByName("Shot Speed Up"))

function afterbrasse:shotSpeedUpCache(player, cacheFlag)
	if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed + 0.2*shot_speed_up_uses_counter
	end
end

afterbrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, afterbrasse.shotSpeedUpCache, Isaac.GetPlayer(0))

--shotspeed dwn
local shot_speed_dwn_uses_counter = 0

function afterbrasse:shotSpeedDownPill(pillId)
	local player = Isaac.GetPlayer(0)
	player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
	shot_speed_dwn_uses_counter = shot_speed_dwn_uses_counter + 1
	player:EvaluateItems()
end
afterbrasse:AddCallback(ModCallbacks.MC_USE_PILL, afterbrasse.shotSpeedDownPill, Isaac.GetPillEffectByName("Shot Speed Down"))

function afterbrasse:shotSpeedDownCache(player, cacheFlag)
	if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed - 0.2*shot_speed_dwn_uses_counter
	end
end

afterbrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, afterbrasse.shotSpeedDownCache, Isaac.GetPlayer(0))

--damage up
local damage_up_uses_counter = 0
function afterbrasse:la_baise_du_dmg_up()
	if damage_up_uses_counter > 6 then
		afterbrasse.damageUpPill = afterbrasse.damageDownPill
	end
end

afterbrasse:AddCallback(ModCallbacks.MC_POST_UPDATE, afterbrasse.la_baise_du_dmg_up)

function afterbrasse:damageUpPill(pillId)
	local player = Isaac.GetPlayer(0)
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	if damage_up_uses_counter < 6 then
		damage_up_uses_counter = damage_up_uses_counter + 1
	end
	player:EvaluateItems()
end
afterbrasse:AddCallback(ModCallbacks.MC_USE_PILL, afterbrasse.damageUpPill, Isaac.GetPillEffectByName("Damage Up"))

function afterbrasse:damageUpCache(player, cacheFlag)
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + 0.5*damage_up_uses_counter
	end
end

afterbrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, afterbrasse.damageUpCache, Isaac.GetPlayer(0))

--damage down
local damage_down_uses_counter = 0

function afterbrasse:damageDownPill(pillId)
	local player = Isaac.GetPlayer(0)
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	damage_down_uses_counter = damage_down_uses_counter + 1
	player:EvaluateItems()
end
afterbrasse:AddCallback(ModCallbacks.MC_USE_PILL, afterbrasse.damageDownPill, Isaac.GetPillEffectByName("Damage Down"))

function afterbrasse:damageDownCache(player, cacheFlag)
	if cacheFlag == CacheFlag.CACHE_DAMAGE and (player.Damage - 0.5*damage_down_uses_counter) > 1 then
		player.Damage = player.Damage - 0.5*damage_down_uses_counter
	end
end

afterbrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, afterbrasse.damageDownCache, Isaac.GetPlayer(0))

--discharge

function afterbrasse:dischargePill(pillId)
	local player = Isaac.GetPlayer(0)
	player:DischargeActiveItem()
end

afterbrasse:AddCallback(ModCallbacks.MC_USE_PILL, afterbrasse.dischargePill, Isaac.GetPillEffectByName("Discharge !"))

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
-----------------------------
-- DEBUG IN GAME
-----------------------------

function afterbrasse:rendertext()
	local room = Game():GetRoom()
	Isaac.RenderText("debug", 50, 100, 255, 255, 255, 255)
end
afterbrasse:AddCallback(ModCallbacks.MC_POST_RENDER, afterbrasse.rendertext)
