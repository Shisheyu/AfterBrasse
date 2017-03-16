
--[[
Krayz
Item : SunWukong (famillier) -- TODO?: Maybe make a Realign Familiars Function(annoying)
Tire de temps à autres une larme feuille qui stopwatch les ennemis
--]]
function _Stillbirth:FAM_SunWukong_init(Familiar) -- init Familiar variables
	local FAM_SunWukongSprite = Familiar:GetSprite()
	Familiar.GridCollisionClass = GridCollisionClass.COLLISION_WALL
	FAM_SunWukongSprite:Play("FloatDown", true);
end

function _Stillbirth:FAM_SunWukong_Update(Familiar) -- Familiar 'AI'
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()
	local ClosestB = nil
	local FAM_SunWukongSprite = Familiar:GetSprite()
	local FamiliarFrameCount = FAM_SunWukongSprite:GetFrame()
	local FamiliarFireDelay = 18

	if (player.FrameCount - g_vars.FAM_SunWukong_oldFrame) <= 0 then
		g_vars.FAM_SunWukong_oldFrame = player.FrameCount
	end
	PlayFamiliarShootAnimation( player:GetFireDirection(), Familiar )
	if IsShooting(player) and (player.FrameCount - g_vars.FAM_SunWukong_oldFrame) > FamiliarFireDelay then
		local v = Vector( math.abs(player:GetLastDirection().X), math.abs(player:GetLastDirection().Y) )
		g_vars.FAM_SunWukong_oldFrame = player.FrameCount
		if (v.X == 1 or v.X == 0) and (v.Y == 1 or v.Y == 0) and g_vars.FAM_SunWukongCounter < 18 then
			local tear = ShootCustomTear( 0, Familiar, player, 1.3, Vector(11, 11), true )
			tear:SetColor( Color( 0.5, 1.0, 0.7, 0.85, 5, 10, 7 ) , 9999, 50, false, false )
			g_vars.FAM_SunWukongCounter = g_vars.FAM_SunWukongCounter + 1
		elseif g_vars.FAM_SunWukongCounter >= 7 then
			local tear = ShootCustomTear( CustomEntities.TearLeaf_Variant, Familiar, player, 1.4, Vector(13, 13), true )
			tear:SetColor( Color( 0.5, 1.0, 0.7, 0.85, 5, 10, 7 ) , 9999, 50, false, false )
			g_vars.FAM_SunWukongCounter = 0
		end
	end
	local bval =  math.abs( player.Position.X - Familiar.Position.X ) + math.abs( player.Position.Y - Familiar.Position.Y )
	if bval > 100 then
		Familiar:MultiplyFriction(0.8) -- normal
		Familiar:FollowParent() -- follow player
	elseif bval > 50 then
		Familiar:MultiplyFriction(bval*0.01) -- SlowDown
		Familiar:FollowParent()
	else
		Familiar:MultiplyFriction(0.2) -- Stop
	end
	--Familiar.Velocity =  Familiar.Velocity:Clamped(-6.0, -6.0, 6.0, 6.0) -- Speed Limiter when follow player
end
_Stillbirth:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, _Stillbirth.FAM_SunWukong_init, Familiars.SunWukong_Familiar_Variant )
_Stillbirth:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, _Stillbirth.FAM_SunWukong_Update, Familiars.SunWukong_Familiar_Variant )

--[[
Drazeb - Krayz
Item : Bomb Bum (famillier)
-- Spawn 1 random trinket every N(defined in the var:"g_vars.FAM_BombCounter") Bombs::
-- Work like the DarkBum: grab all the bombs he can in the room then come back to the player and spawn the trinket if he IsOkForIt.
--]]
function _Stillbirth:FAM_BombBum_init(Familiar) -- init Familiar variables
    local FAM_BBSprite = Familiar:GetSprite()
    Familiar.GridCollisionClass = GridCollisionClass.COLLISION_WALL
    FAM_BBSprite:Play("FloatDown", true); -- Plays his float anim
end

function _Stillbirth:FAM_BombBum_Update(Familiar) -- Familiar AI
    local player = Isaac.GetPlayer(0)
    local entities = Isaac.GetRoomEntities()
    local ClosestB = nil
    local tmp = 0xFFFFFF
    local FAM_BBSprite = Familiar:GetSprite()
    local FamiliarFrameCount = FAM_BBSprite:GetFrame()
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
                g_vars.FAM_BombCounter = g_vars.FAM_BombCounter + 1
            elseif entities[ClosestB].SubType == 2 then
                g_vars.FAM_BombCounter = g_vars.FAM_BombCounter + 2
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
    if ( (g_vars.FAM_BombCounter-g_vars.FAM_nBombBeforDrop) >= 0 and bval < 200 and not ClosestB ) or FAM_BBSprite:IsPlaying("PreSpawn") then -- Drop a Random Trinket every 10 Bombs when near player if no more bombs in the room
        if not FAM_BBSprite:IsPlaying("PreSpawn") and not FAM_BBSprite:IsPlaying("Spawn") then
            FAM_BBSprite:Play("PreSpawn", true)
        end
        if FamiliarFrameCount == 8 and not FAM_BBSprite:IsPlaying("Spawn") then -- Hum.IsOk.
            Isaac.Spawn(5, 350, 0, Familiar.Position, Vector(0, 0), player) -- Drop Rand Trinket
            g_vars.FAM_BombCounter = g_vars.FAM_BombCounter - g_vars.FAM_BombCounter
            if not FAM_BBSprite:IsPlaying("Spawn") then
                FAM_BBSprite:Play("Spawn", true)
            end
        end
    end
    if not FAM_BBSprite:IsPlaying("Spawn") and not FAM_BBSprite:IsPlaying("PreSpawn") and not FAM_BBSprite:IsPlaying("FloatDown") then
        FAM_BBSprite:Play("FloatDown", true)
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, _Stillbirth.FAM_BombBum_init, Familiars.FAM_BombBumFamiliarVariant )
_Stillbirth:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, _Stillbirth.FAM_BombBum_Update, Familiars.FAM_BombBumFamiliarVariant )

--[[
Dionea Muscipula

Azqswx
]]--


local Root = {};
local eating = false;

function _Stillbirth:Dionea_onPlayerInit()
	g_vars.dionea_tearsCount = 0;
	g_vars.dionea_L1 = nil;
	g_vars.dionea_L2 = nil;
	g_vars.dionea_L1exists = false;
	g_vars.dionea_L1dead = false;
	g_vars.dionea_L2exists = false;
	g_vars.dionea_L2dead = false;
	g_vars.dionea_L3exists = false;
end

function _Stillbirth:Dionea_onEvaluateCacheL1()
	local player = Isaac.GetPlayer(0);
	if player:HasCollectible(Items.DioneaFamIdL1_i) and g_vars.dionea_L1exists == false and g_vars.dionea_L1dead == false then
		L1 = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, Familiars.DioneaFamVariantL1, 0, player.Position, Vector(0,0),player);
		g_vars.dionea_L1exists = true;
	end
end

function _Stillbirth:Dionea_onFamiliarUpdateL1(DioneaFam)
	local player = Isaac.GetPlayer(0);
	DioneaFam.OrbitDistance = Vector(25,25);
	DioneaFam.OrbitLayer = 10;
	DioneaFam.OrbitSpeed = 0.02;
	DioneaFam.Velocity = DioneaFam:GetOrbitPosition(player.Position + player.Velocity) - DioneaFam.Position
	local L1Sprite = DioneaFam:GetSprite()
    L1Sprite:Play("Float", true);
	L1Sprite:Update()
end

function _Stillbirth:Dionea_onInitL1(DioneaFam)
	local player = Isaac.GetPlayer(0)
	DioneaFam.OrbitDistance = Vector(25,25);
	DioneaFam.OrbitLayer = 10;
	DioneaFam.OrbitSpeed = 0.03;
	local L1Sprite = DioneaFam:GetSprite()
    L1Sprite:Play("Float", true);
	L1Sprite:Update()
end

function _Stillbirth:Dionea_onFamiliarUpdateL2(DioneaFam)
	local player = Isaac.GetPlayer(0);
	DioneaFam.OrbitDistance = Vector(25,25);
	DioneaFam.OrbitLayer = 10;
	DioneaFam.OrbitSpeed = 0.02;
	DioneaFam.Velocity = DioneaFam:GetOrbitPosition(player.Position + player.Velocity) - DioneaFam.Position
	local L2Sprite = DioneaFam:GetSprite()
    L2Sprite:Play("Float", true);
	L2Sprite:Update();
end

 function _Stillbirth:Dionea_onInitL2(DioneaFam)
	local player = Isaac.GetPlayer(0)
	DioneaFam.OrbitDistance = Vector(25,25);
	DioneaFam.OrbitLayer = 10;
	DioneaFam.OrbitSpeed = 0.07;
	local L2Sprite = DioneaFam:GetSprite()
    L2Sprite:Play("Float", true);
	L2Sprite:Update()
end

function _Stillbirth:Dionea_onFamiliarUpdateL3(DioneaFam)
	local player = Isaac.GetPlayer(0);
	local ClosestB = nil;
	local bvalE = nil;
    local tmp = 0xFFFFFF;
	local entities = Isaac.GetRoomEntities();
	local L3Sprite = DioneaFam:GetSprite();
	local FamiliarFrameCount = L3Sprite:GetFrame();
	L3Sprite.PlaybackSpeed = 0.50;
	
	for i = 1,#Root do
		Root[i]:FollowPosition(player.Position:__mul( #Root+1-i ):__add(g_vars.dionea_L3.Position:__mul(i)):__div(#Root+1));
		Root[i]:MultiplyFriction(10.0);
	end

	local bval =  math.abs( player.Position.X - DioneaFam.Position.X ) + math.abs( player.Position.Y - DioneaFam.Position.Y );
	for i = 1, #entities do
        if entities[i]:IsVulnerableEnemy() then
            local bval =  math.abs( entities[i].Position.X - DioneaFam.Position.X ) + math.abs( entities[i].Position.Y - DioneaFam.Position.Y )
            if tmp > bval then
                tmp = bval
                ClosestB = i
            end
        end
    end
    if ClosestB ~= nil then
    	bvalE = math.abs( entities[ClosestB].Position.X - player.Position.X ) + math.abs( entities[ClosestB].Position.Y - player.Position.Y );
    end
    if eating then
    	eatingDist = 300;
    else
    	eatingDist = 200;
    end
	if ClosestB and bvalE <= eatingDist then
		if not L3Sprite:IsPlaying("Eat") then
			L3Sprite:Play("Eat",true);
			L3Sprite:Update()
		end
		if not SFXManager():IsPlaying(100) and L3Sprite:IsEventTriggered("Eating") then
			SFXManager():Play(100,1.0,1,false,1.0)			--Joue son Carnivore
		end      
		local bval =  math.abs( entities[ClosestB].Position.X - DioneaFam.Position.X ) + math.abs( entities[ClosestB].Position.Y - DioneaFam.Position.Y )
        DioneaFam:FollowPosition( entities[ClosestB].Position );  
        eating = true; 
        if bval >= 5 then 
        	eating = false;
        end
    else
    	if FamiliarFrameCount >= 9 and L3Sprite:IsPlaying("Eat") then
			L3Sprite:Play("Float", true)
    		L3Sprite:Update();
		end
        if bval >= 200 then
            DioneaFam:MultiplyFriction(0.5); -- normal
            DioneaFam:FollowPosition( player.Position ); -- follow player
        elseif bval >= 5 then
        	DioneaFam:MultiplyFriction(1.0);
        	DioneaFam:FollowPosition(player.Position);
        else
            DioneaFam:MultiplyFriction(0.2); -- Stop
        end
    end    
end

 function _Stillbirth:Dionea_onInitL3(DioneaFam)
	local player = Isaac.GetPlayer(0)
	DioneaFam:FollowParent();
	DioneaFam.Velocity = DioneaFam.Velocity:Clamped(-5.5, -5.5, 5.5, 5.5)
	local L3Sprite = DioneaFam:GetSprite()
    L3Sprite:Play("Float", true);
	L3Sprite:Update()
end

 function _Stillbirth:Dionea_onGameUpdate()
	local entities = Isaac.GetRoomEntities();
	local player = Isaac.GetPlayer(0);
	local Nbr = 10;
	for i = 1, #entities do
		if entities[i].Type == EntityType.ENTITY_PROJECTILE and g_vars.dionea_L1exists == true then
			local distance = ((g_vars.dionea_L1.Position.X-entities[i].Position.X)^2+(g_vars.dionea_L1.Position.Y-entities[i].Position.Y)^2)^(1/2);
			if distance <= 18 then
				g_vars.dionea_tearsCount = g_vars.dionea_tearsCount+1;
				entities[i]:Kill();
			end
		end
		if entities[i].Type == EntityType.ENTITY_PROJECTILE and g_vars.dionea_L2exists == true then
			local distance = ((g_vars.dionea_L2.Position.X-entities[i].Position.X)^2+(g_vars.dionea_L2.Position.Y-entities[i].Position.Y)^2)^(1/2);
			if distance <= 20 then
				g_vars.dionea_tearsCount = g_vars.dionea_tearsCount+1;
				entities[i]:Kill();
			end
		end
	end
	if g_vars.dionea_tearsCount >= 20 and g_vars.dionea_tearsCount <= 30 and g_vars.dionea_L2exists == false then
		g_vars.dionea_L2 = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, Familiars.DioneaFamVariantL2, 0, g_vars.dionea_L1.Position, Vector(0,0),player);
		g_vars.dionea_L2exists = true;
		g_vars.dionea_L1:Remove();
		g_vars.dionea_L1exists = false;
		g_vars.dionea_L1dead = true;
	end
	if g_vars.dionea_tearsCount >= 50 and g_vars.dionea_tearsCount <= 60 and g_vars.dionea_L3exists == false then
		g_vars.dionea_L3 = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, Familiars.DioneaFamVariantL3, 0, player.Position, Vector(0,0),player);
		for i = 1, Nbr do
			Root[i] = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, Familiars.DioneaFamVariantR, 0, player.Position, Vector(0,0), player):ToFamiliar();
		end
		g_vars.dionea_L3exists = true;
		local L3Sprite = L3:GetSprite()
		g_vars.dionea_L2:Remove();
		g_vars.dionea_L2exists = false;
		g_vars.dionea_L2dead = true;
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.Dionea_onGameUpdate)
_Stillbirth:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, _Stillbirth.Dionea_onPlayerInit);

_Stillbirth:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, _Stillbirth.Dionea_onFamiliarUpdateL1, Familiars.DioneaFamVariantL1)
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.Dionea_onEvaluateCacheL1)
_Stillbirth:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, _Stillbirth.Dionea_onInitL1, Familiars.DioneaFamVariantL1)

_Stillbirth:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, _Stillbirth.Dionea_onFamiliarUpdateL2, Familiars.DioneaFamVariantL2)
_Stillbirth:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, _Stillbirth.Dionea_onInitL2, Familiars.DioneaFamVariantL2)

_Stillbirth:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, _Stillbirth.Dionea_onFamiliarUpdateL3, Familiars.DioneaFamVariantL3)
_Stillbirth:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, _Stillbirth.Dionea_onInitL3, Familiars.DioneaFamVariantL3)

--[[
Item : Electron
Type : Familiar (orbital)
By : Dogeek & Krayz because Dogeek is REALLY BAD
Date : 2017-03-08

----------------------------
-- GAME VARIABLES
----------------------------
local electron_index = 0
local MAX_electron_index = 64
local INCREMENT = 4
local BASE_DAMAGE = MAX_electron_index * 2
local increase = true
-----------------------------
-- CODE
-----------------------------

function _Stillbirth:electronInit(fam) -- init Familiar variables
    local electronSprite = fam:GetSprite()
    fam.OrbitDistance = Vector(44,44)
	fam.OrbitLayer = 1
	fam.OrbitSpeed = 0.1
	fam.Friction = 1
    fam.GridCollisionClass = GridCollisionClass.COLLISION_NONE
    electronSprite:Play("FloatDown", true); -- Plays his float anim
end

local orbSpeed = 0.0
function _Stillbirth:electronUpdate(fam)
	local player = Isaac.GetPlayer(0)
	orbSpeed = inQuad(electron_index, 1, 500-electron_index, 500)/50
	fam.Velocity = fam:GetOrbitPosition(player.Position:__sub(fam.Position))
	fam.OrbitDistance = Vector(44+electron_index*1.8,44+electron_index*1.8)
	fam.CollisionDamage = BASE_DAMAGE/electron_index
	fam:MultiplyFriction( 0.2 + orbSpeed ) -- MultiplyFriction for a better control over speed
	fam.OrbitSpeed = 0.1 -- this is pretty not very actually maybe isnt super uper dupper good but can't really change it
end

function _Stillbirth:updateelectron_index()
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()
	local battery_spawned = false
	local battery = nil
	BASE_DAMAGE = MAX_electron_index *2/3.5*player.Damage
	if player:HasCollectible(Items.electron_i) then
		for i=1, #entities do
			e = entities[i]
			if e.Type == 5 and e.Variant == 90 then
				battery_spawned = true
				battery = e:ToPickup()
			end
		end
		if battery_spawned and player:NeedsCharge() and math.abs((player.Position-battery.Position):Length()) <= 28 then
				Isaac.Spawn(Familiars.electronFamiliar, Familiars.electronFamiliarVariant, 0, player.Position, Vector(0, 0), player)
				g_vars.numberOfElectrons = g_vars.numberOfElectrons + 1
				battery:PlayPickupSound()
				battery:Remove()
				player:FullCharge()
		end
		if player.FrameCount&3 == 0 then
			if electron_index < MAX_electron_index  and increase then
				electron_index = electron_index + INCREMENT
				if electron_index == MAX_electron_index then
					increase = false
				end
			elseif electron_index >= INCREMENT and not increase then
				electron_index = electron_index - INCREMENT
				if electron_index == 0 then
					increase = true
				end
			end
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, _Stillbirth.electronInit, Familiars.electronFamiliarVariant )
_Stillbirth:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, _Stillbirth.electronUpdate, Familiars.electronFamiliarVariant )
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.updateelectron_index)]]--
