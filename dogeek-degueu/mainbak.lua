--[[
Trinket : Burnt marshmallow : petrified poop des feux
-Dogeek-
]]--
--chance : 20% base + 40% trinket
local afterbrasse = RegisterMod("Afterbrasse", 1);
local burntMarshmallow = Isaac.GetTrinketIdByName("Burnt Marshmallow");
local BMLastRoom = nil
local fireArr = {}

local function doesFireLoot(fireplace)
	local entities = Isaac.GetRoomEntities()
	for i=1, #entities do
		if entities[i].Type ~= EntityType.ENTITY_FIREPLACE then
			if entities[i].Position == fireplace.Position then
				return false
			else
				return true
			end
		end
	end
end

local function FireLoot( ent, fireArr )
    if fireArr then
        for j=1, #fireArr do
            if ent.Type ~= EntityType.ENTITY_FIREPLACE then
                local v = fireArr[j].Position:__sub( ent.Position )
                if v.X == 0 and v.Y == 0 then
                    return 0
                end
            elseif ( ent.Type == EntityType.ENTITY_FIREPLACE and ent.HitPoints == 1 ) then
                ent.HitPoints = 0 -- shhhht...IsOk.
                if ent.Variant  == 0 or ent.Variant  == 1 then
                    SpawnLoot( ent.Position, false)
                elseif ent.Variant == 2 or ent.Variant == 3 then
                    db_e = "ah.ah.ah." -- Blue fire & purple spawn
                end
                return 1
            end
        end
    end
    return nil
end

local function SpawnLoot(Position, blue)
	local spawner = Isaac.GetPlayer(0)
	local SpawnChance = 0.8
	local loots = {}
	loots.HEART = 0.25
	loots.COIN = 0.75
	local hearts = {}
	hearts.HALF = 0.55
	hearts.FULL = 0.3
	hearts.SOUL = 0.1
	hearts.ETERNAL = 0.05
	local blueHearts = {}
	blueHearts.SOUL = 0.75
	blueHearts.HALFSOUL = 25
	local coins = {}
	coins.PENNY = 0.78
	coins.NICKEL = 0.15
	coins.DIME = 0.05
	coins.LUCKY = 0.02
	local rand = math.random()
	if rand <= SpawnChance then
		rand = math.random()
		if blue then
			if rand <= blueHearts.SOUL then
				rand = math.random()
				if rand >= hearts.FULL and rand <= hearts.SOUL then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, Position, Vector(0,0), spawner)
				else
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALFSOUL, Position, Vector(0,0), spawner)
				end
			end
		else
			if rand < loots.HEART then
				rand = math.random()
				if rand <= hearts.HALF then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, Position, Vector(0,0), spawner)
				elseif rand >= hearts.HALF and rand <= hearts.FULL then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, Position, Vector(0,0), spawner)
				elseif rand >= hearts.FULL and rand <= hearts.SOUL then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, Position, Vector(0,0), spawner)
				else
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, Position, Vector(0,0), spawner)
				end
			else
				rand = math.random()
				if rand <= coins.PENNY then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, Position, Vector(0,0), spawner)
				elseif rand >= coins.PENNY and rand <= coins.NICKEL then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, Position, Vector(0,0), spawner)
				elseif rand >= coins.PENNY and rand <= coins.NICKEL then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DIME, Position, Vector(0,0), spawner)
				else
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_LUCKYPENNY, Position, Vector(0,0), spawner)
				end
			end
		end
	end
end

function afterbrasse:burntMarshmallowUpdate()
    local player = Isaac.GetPlayer(0)
    local entities = Isaac.GetRoomEntities()
    local room = Game():GetRoom()
    local index = 1

    if BMLastRoom ~= room:GetDecorationSeed() then
        for i=1, #entities do
            if entities[i].Type == EntityType.ENTITY_FIREPLACE then
                table.insert( fireArr, entities[i] )
                index = index + 1
            end
        end
        BMLastRoom = room:GetDecorationSeed()
    end
    for i=1, #fireArr do
		if not doesFireLoot(fireArr[i]) then
			local t = fireArr[i].Variant
			if t == 2 or t == 3 then -- 2=BlueFire 3=PurpleFire
		        	SpawnLoot(fireArr[i].Position, true)
		    elseif t == 0 or t == 1 then
		        	SpawnLoot(fireArr[i].Position, false)
		    end
		--[[if player:HasTrinket(burntMarshmallow) then
		    for i=1, #entities do
		        local t = FireLoot( entities[i], fireArr )
		        if t == 2 or t == 3 then -- 2=BlueFire 3=PurpleFire
		        	SpawnLoot(entities[i].Position, true)
		        elseif t == 0 or t == 1 then
		        	SpawnLoot(entities[i].Position, false)
		        end
		    end
		--end--]]
		end
    end
end

afterbrasse:AddCallback( ModCallbacks.MC_POST_UPDATE, afterbrasse.burntMarshmallowUpdate);
