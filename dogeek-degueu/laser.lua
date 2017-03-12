--[[
Transfo L.A.S.E.R.
3 Items parmi : Tech 1 / Tech 2 / Tech.5 / Tech X / Robo Baby 1&2 / Tech 0

Effet : Tous les lasers possédés gagnent un effet supplémentaire qui peut changer de manière aléatoire à chaque tir et donc créer une rotation des effets. L’effet rouge est un bonus x1,5 damage sur le tir en question, le bonus bleu est homming shot et le bonus jaune paralyse les ennemis touchés.

--Dogeek
]]--

function print(...)
    local str, sep = "", ""
    for i=1, select('#', ...) do
        str = str .. sep .. tostring(select(i, ...))
        sep = '\t'
    end
    return Isaac.DebugString(str)
end

local afterbrasse = RegisterMod("Afterbrasse", 1);

local function IsShooting(player)
	if player:GetFireDirection() == -1 then
		return false
	else
		return true
	end
end

local function boolToInt(bool)
	if bool then
		return 1
	else
		return 0
	end
end

local function hasLaser(player)
	local hasTech0 = 0 --boolToInt(player:HasCollectible(Isaac.GetItemIdByName("Technology 0")))
	local hasTech1 = boolToInt(player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY))
	local hasTech2 = boolToInt(player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2))
	local hasTechX = boolToInt(player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_5))
	local hasTech5 = boolToInt(player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X))
	local hasRB1 = boolToInt(player:HasCollectible(CollectibleType.COLLECTIBLE_ROBO_BABY))
	local hasRB2 = boolToInt(player:HasCollectible(CollectibleType.COLLECTIBLE_ROBO_BABY_2))
	if (hasTech0 + hasTech1 + hasTech2 + hasTechX + hasTech5 + hasRB1 + hasRB2) >= 3 then
		return true
	else
		return false
	end
end

function afterbrasse:LaserUpdate()
	local player = Isaac.GetPlayer(0)
	local blue = Color(0, 0, 0, 1, 0, 200, 255)
	local red = Color(0, 0, 0, 1, 255, 0, 0)
	local yellow = Color(0, 0, 0, 1, 255, 238, 0)
	if hasLaser(player) and IsShooting(player) then
		local entities = Isaac.GetRoomEntities()
		for i=1, #entities do
			if entities[i].Type == EntityType.ENTITY_LASER and (entities[i].Parent.Type == EntityType.ENTITY_PLAYER or entities[i].Parent.Type == EntityType.ENTITY_FAMILIAR) then
				local laser = entities[i]:ToLaser()
				if not laser:HasEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH) then
					local rand = math.random(1, 3)
					laser:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
					if rand == 1 then --Damage Up
						laser.CollisionDamage = laser.CollisionDamage * 1.5
						laser:SetColor(red, 60, 999, false, false)
					elseif rand == 2 then --paralysis
						laser:AddFreeze(EntityRef(player), 180)--180 frames de freeze
						laser:SetColor(yellow, 60, 999, false, false)
					else --homing
						--laser:SetHomingType(0) --LaserHomingType Type ??
						--player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_SPOON_BENDER, false)
						laser.TearFlags = 1<<2
						laser:SetColor(blue, 60, 999, false, false)
					end
				end
			end
		end
	end
end

afterbrasse:AddCallback(ModCallbacks.MC_POST_UPDATE, afterbrasse.LaserUpdate)
