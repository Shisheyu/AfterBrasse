--[[
Item : Electron
Type : Familiar (orbital)
By : Dogeek & Krayz because Dogeek is REALLY BAD
Date : 2017-03-08
]]--

local afterbrasse = RegisterMod("AfterBrasse", 1)

----------------------------
-- GAME VARIABLES
----------------------------

local electronFamiliar = Isaac.GetEntityTypeByName("fam_electron")
local electronFamiliarVariant = Isaac.GetEntityVariantByName("fam_electron")
local electron = Isaac.GetItemIdByName("TestFamiliar")
local hasElectronSpawned = false
local index = 0
local MAX_INDEX = 64
local INCREMENT = 4
local BASE_DAMAGE = MAX_INDEX * 2
local increase = true
local db = ""
local needChargePrevious = false

-----------------------------
-- CODE
-----------------------------

function afterbrasse:electronCache() -- If player has the item, spawns Familiar::(Opti)In a CACHEUPDATE so it's not Verified every frames
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(electron) and not hasElectronSpawned then
        Isaac.Spawn(electronFamiliar, electronFamiliarVariant, 0, player.Position, Vector(0, 0), player)
        hasElectronSpawned = true
    end
end

local function Q(t, b, c, d)	return c * ((t / d) ^ 2) + b end  -- accelerating / decelerating

function afterbrasse:electronInit(fam) -- init Familiar variables
    local electronSprite = fam:GetSprite()
    fam.OrbitDistance = Vector(44,44)
	fam.OrbitLayer = 1
	fam.OrbitSpeed = 0.1
	fam.Friction = 1
    fam.GridCollisionClass = GridCollisionClass.COLLISION_NONE
    electronSprite:Play("FloatDown", true); -- Plays his float anim
end
local orbSpeed = 0.0
local ply_chargeneeded = nil
function afterbrasse:electronUpdate(fam)
	local player = Isaac.GetPlayer(0)
	orbSpeed = Q(index, 1, 500-index, 500)/50
	fam.Velocity = fam:GetOrbitPosition(player.Position:__sub(fam.Position))
	fam.OrbitDistance = Vector(44+index*1.8,44+index*1.8)
	fam.CollisionDamage = BASE_DAMAGE/index
	fam:MultiplyFriction( 0.2 + orbSpeed ) -- MultiplyFriction for a better control over speed
	fam.OrbitSpeed = 0.1 -- this is pretty not very actually maybe isnt super uper dupper good but can't really change it
end

function afterbrasse:updateIndex()
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()
	local battery_spawned = false
	local battery = nil
	BASE_DAMAGE = MAX_INDEX *2/3.5*player.Damage
	if player:HasCollectible(electron) then
		if player.FrameCount == 1 then ply_chargeneeded = player:NeedsCharge() end
		for i=1, #entities do
			e = entities[i]
			if e.Type == 5 and e.Variant == 90 then
				battery_spawned = true
				battery = e:ToPickup()
			end
		end
		db = tostring(ply_chargeneeded)
		if battery_spawned and player:NeedsCharge() and math.abs((player.Position-battery.Position):Length()) <= 28 then
				Isaac.Spawn(electronFamiliar, electronFamiliarVariant, 0, player.Position, Vector(0, 0), player)
				battery:PlayPickupSound()
				battery:Remove()
				player:FullCharge()
		end

		if player.FrameCount&3 == 0 then
			if index < MAX_INDEX  and increase then
				index = index + INCREMENT
				if index == MAX_INDEX then
					increase = false
				end
			elseif index >= INCREMENT and not increase then
				index = index - INCREMENT
				if index == 0 then
					increase = true
				end
			end
		end
	end
end

afterbrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, afterbrasse.electronCache)
afterbrasse:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, afterbrasse.electronInit, electronFamiliarVariant )
afterbrasse:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, afterbrasse.electronUpdate, electronFamiliarVariant )
afterbrasse:AddCallback(ModCallbacks.MC_POST_UPDATE, afterbrasse.updateIndex)
-----------------------------
-- DEBUG IN GAME
-----------------------------

function afterbrasse:rendertext()
	local room = Game():GetRoom()
	Isaac.RenderText(db, 50, 100, 255, 255, 255, 255)
end
afterbrasse:AddCallback(ModCallbacks.MC_POST_RENDER, afterbrasse.rendertext)
