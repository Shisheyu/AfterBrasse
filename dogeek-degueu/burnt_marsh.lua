--Spawn double si 

local afterbrasse = RegisterMod("BurntMarshmallow", 1);
local burntMash = Isaac.GetTrinketIdByName("TestTrinket");

local BMLastRoom = nil
local fireArr = {}

local function SpawnLoot(Position, blue)
	local spawner = Isaac.GetPlayer(0)
	local SpawnChance = 0.4
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
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL, Position, Vector(0,0), spawner)
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

--40%
local Fcnt = 0 --
local roomDone = nil
function afterbrasse:burntMash_FireLoot( player, ent, fireArr )
	local game = Game()
	if fireArr and ent then
		if game:GetFrameCount() % 2 == 0 then
			for j=1, #fireArr do
				local v = fireArr[j].Position:__sub( ent.Position )
				if v.X == 0 and v.Y == 0  and ent.Type ~= EntityType.ENTITY_FIREPLACE and ent.Type ~= fireArr[j].Type then
					table.remove(fireArr, j)
					return
				elseif ( ent.Type == EntityType.ENTITY_FIREPLACE and ent.HitPoints == 1 ) and Fcnt == 10 then
					if ent.Variant  == 0 or ent.Variant  == 1 then
						SpawnLoot( ent.Position , false )
					elseif ent.Variant == 2 or ent.Variant == 3 then
						SpawnLoot( ent.Position , true ) -- Blue fire & purple spawn:
					end
					ent.HitPoints = 0 -- .IsOk.
					Fcnt = 0
				end
			end
		end
	end
end

start = false --
function afterbrasse:burntMash_update()
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()
	local room = Game():GetRoom()

	if BMLastRoom ~= room:GetDecorationSeed() then
		fireArr = {}
		for i=1, #entities do
			if entities[i].Type == EntityType.ENTITY_FIREPLACE and entities[i].HitPoints > 1 then
				table.insert( fireArr, entities[i] )
			end
		end
		BMLastRoom = room:GetDecorationSeed()
	end
	--if player:HasTrinket(burntMash) then

			for i=1, #entities do -- n frame per entity in the room
				if i+1 <= #entities then
					local v = entities[i].Position:__sub( entities[i + 1].Position )
					if entities[i].Type == 33 and entities[i].HitPoints == 1 then --and entities[i + 1].Type == 5 and v.X == 0 and v.Y == 0 then
						start = true
					end
					if v.X == 0 and v.Y == 0  and entities[i].Type ~= EntityType.ENTITY_FIREPLACE and entities[i].Type ~= entities[i + 1].Type then
					else--
						--FireLoot( player, entities[i], fireArr )
					end--
				end
				afterbrasse:burntMash_FireLoot( player, entities[i], fireArr )
			end

	--end
	if fireArr and start then
		Fcnt = Fcnt + 1
	end
	if Fcnt > 10 then
		Fcnt = 0
	end
end
afterbrasse:AddCallback( ModCallbacks.MC_POST_UPDATE, afterbrasse.burntMash_update);
afterbrasse:AddCallback( ModCallbacks.MC_POST_UPDATE, afterbrasse.burntMash_FireLoot);
