--[[
Drazeb - Krayz
Item : Bomb Bum (famillier)
-- Spawn 1 random trinket every N(defined in the var:"FAMbb_nBombBeforDrop") Bombs::
-- Work like the DarkBum: grab all the bombs he can in the room then come back to the player and spawn the trinket if he IsOkForIt.
--]]
local Afterbrasse = RegisterMod("FAMbb", 1)
local FAMbb_BombBumFamiliar = Isaac.GetEntityTypeByName("fam_BombBum")
local FAMbb_BombBumFamiliarVariant = Isaac.GetEntityVariantByName("fam_BombBum")
local FAMbb_BombBum_ITEM_ID = Isaac.GetItemIdByName("fam_BombBum_I")

local FAMbb_BombBumExists = false -- need save
local FAMbb_BombCounter = 0
local FAMbb_nBombBeforDrop = 10 -- Num of bomb the bum will eat before vomiting a trinket

function Afterbrasse:FAMbb_BombBum_PlayerIni() -- player init
    FAMbb_nBombBeforDrop = 10
    FAMbb_BombCounter = 0
    FAMbb_BombBumExists = false
end

function Afterbrasse:FAMbb_BombBum_init(Familiar) -- init Familiar variables
    local FAMbb_BBSprite = Familiar:GetSprite()
    Familiar.GridCollisionClass = GridCollisionClass.COLLISION_WALL
    FAMbb_BBSprite:Play("FloatDown", true); -- Plays his float anim
end

function Afterbrasse:FAMbb_BombBumItemEvCache() -- If player has the item, spawns Familiar::(Opti)In a CACHEUPDATE so it's not Verified every frames
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(FAMbb_BombBum_ITEM_ID) and not FAMbb_BombBumExists then -- BombBum
        Isaac.Spawn(FAMbb_BombBumFamiliar, FAMbb_BombBumFamiliarVariant, 0, player.Position, Vector(0, 0), player)
        FAMbb_BombBumExists = true
    end
end

function Afterbrasse:FAMbb_BombBum_Update(Familiar) -- Familiar AI
    local player = Isaac.GetPlayer(0)
    local entities = Isaac.GetRoomEntities()
    local ClosestB = nil
    local tmp = 0xFFFFFF
    local FAMbb_BBSprite = Familiar:GetSprite()
    local FamiliarFrameCount = FAMbb_BBSprite:GetFrame()
    local bval =  math.abs( player.Position.X - Familiar.Position.X ) + math.abs( player.Position.Y - Familiar.Position.Y )

    for i = 1, #entities do
        if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_BOMB and ( entities[i].SubType == 1 or entities[i].SubType == 2 ) then
            local bval =  math.abs( entities[i].Position.X - Familiar.Position.X ) + math.abs( entities[i].Position.Y - Familiar.Position.Y )
            if tmp > bval then
                tmp = bval
                ClosestB = i
            end
        end
    end
    if ClosestB then
        local bval =  math.abs( entities[ClosestB].Position.X - Familiar.Position.X ) + math.abs( entities[ClosestB].Position.Y - Familiar.Position.Y )
        Familiar:FollowPosition( entities[ClosestB].Position ) -- Fam go to closest bomb
        Familiar.Velocity =  Familiar.Velocity:Clamped(-5.5, -5.5, 5.5, 5.5) -- Speed Limiter when going to bomb
        if bval <= 25  and FamiliarFrameCount % 10 == 0 then --IsOk.
            if entities[ClosestB].SubType == 1 then
                FAMbb_BombCounter = FAMbb_BombCounter + 1
            elseif entities[ClosestB].SubType == 2 then
                FAMbb_BombCounter = FAMbb_BombCounter + 2
            end
            entities[ClosestB]:Remove()
        end
    else
        if bval > 100 then
            Familiar:MultiplyFriction(1.0) -- normal
            Familiar:FollowPosition( player.Position ) -- follow player
        elseif bval > 40 then
            Familiar:MultiplyFriction(bval*0.01) -- SlowDown
            Familiar:FollowPosition( player.Position )
        else
            Familiar:MultiplyFriction(0.2) -- Stop
        end
        Familiar.Velocity =  Familiar.Velocity:Clamped(-4.0, -4.0, 4.0, 4.0) -- Speed Limiter when follow player
    end
    if ( (FAMbb_BombCounter-FAMbb_nBombBeforDrop) >= 0 and bval < 200 and not ClosestB ) or FAMbb_BBSprite:IsPlaying("PreSpawn") then -- Drop a Random Trinket every 10 Bombs when near player if no more bombs in the room
        if not FAMbb_BBSprite:IsPlaying("PreSpawn") and not FAMbb_BBSprite:IsPlaying("Spawn") then
            FAMbb_BBSprite:Play("PreSpawn", true)
        end
        if FamiliarFrameCount == 8 and not FAMbb_BBSprite:IsPlaying("Spawn") then -- Hum.IsOk.
            Isaac.Spawn(5, 350, 0, Familiar.Position, Vector(0, 0), player) -- Drop Rand Trinket
            FAMbb_BombCounter = FAMbb_BombCounter - FAMbb_nBombBeforDrop
            if not FAMbb_BBSprite:IsPlaying("Spawn") then
                FAMbb_BBSprite:Play("Spawn", true)
            end
        end
    end
    if not FAMbb_BBSprite:IsPlaying("Spawn") and not FAMbb_BBSprite:IsPlaying("PreSpawn") and not FAMbb_BBSprite:IsPlaying("FloatDown") then
        FAMbb_BBSprite:Play("FloatDown", true)
    end
end

Afterbrasse:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Afterbrasse.FAMbb_BombBum_PlayerIni);
Afterbrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Afterbrasse.FAMbb_BombBumItemEvCache)
Afterbrasse:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Afterbrasse.FAMbb_BombBum_init, FAMbb_BombBumFamiliarVariant )
Afterbrasse:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Afterbrasse.FAMbb_BombBum_Update, FAMbb_BombBumFamiliarVariant )
