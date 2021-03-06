--[[
Debug item to spawn every custom item we have
--Dogeek

function _Stillbirth:onUseDebugItem()
	local center = Game():GetRoom():GetCenterPos()
	for i=1, #Items do
		Isaac.Spawn(5, 100, Items[i], Isaac.GetFreeNearPosition(center, 32.0), Vector(0,0), player)
	end
	return true
end
_Stillbirth:AddCallback(ModCallbacks.MC_USE_ITEM, _Stillbirth.onUseDebugItem, Items.debug_i)
]]--
--[[
Active Item: "Cricket's Paw"
-Sliost-
--Dogeek
--]]
function _Stillbirth:UseCricketsPaw()
    local player = Isaac.GetPlayer(0)
    local soulHearts = player:GetSoulHearts()

    if g_vars.cricketsPaw_Uses < 5 then
        -- More than 3 read hearts
        if player:GetMaxHearts() > 4 or (player:GetMaxHearts() == 4 and (player:GetBlackHearts() > 1 or soulHearts >1)) then
            player:AddMaxHearts(-4)
            g_vars.cricketsPaw_had = true
            g_vars.cricketsPaw_Uses = math.min( g_vars.cricketsPaw_Uses + 1, 5 )
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            return true
            -- More than 3 full soul/black hearts
        elseif (player:GetMaxHearts() == 0 and soulHearts > 6) or (player:GetMaxHearts() ~= 0 and soulHearts >= 6) then
            for i=1,6 do
                player:RemoveBlackHeart(soulHearts - i)
            end
            player:AddSoulHearts(-6)
            g_vars.cricketsPaw_had = true
            g_vars.cricketsPaw_Uses = math.min( g_vars.cricketsPaw_Uses + 1, 5 )
            player:AddCacheFlags( CacheFlag.CACHE_DAMAGE )
            return true
        end
    end
end

function _Stillbirth:HasCricketsPawUsesCacheUpdate(player, cacheFlag)
	local dmg = 0
    if g_vars.cricketsPaw_had then
    	if player:HasCollectible(Items.spinach_i) then dmg = dmg+1 end
    	if player:HasCollectible(Items.hot_pizza_slice_i) then dmg = dmg+1 end
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
        	g_vars.cricketspaw_multiplier = (1+g_vars.cricketsPaw_Uses*0.2)
        	player.Damage = DamageToSet(player, dmg, g_vars.cricketspaw_multiplier)
        end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_USE_ITEM, _Stillbirth.UseCricketsPaw, Items.cricketsPaw_i)
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.HasCricketsPawUsesCacheUpdate)

--[[
Passive item: "Money = Luck"
-Krayz-
--]]
function _Stillbirth:MoneyLuck_obj()
    local player = Isaac.GetPlayer(0)
    if ( player:HasCollectible( Items.moneyLuck_i ) and g_vars.MoneyIsPower_OldCoins ~= player:GetNumCoins() ) then
        player:AddCacheFlags(CacheFlag.CACHE_LUCK)
        player:EvaluateItems(); g_vars.MoneyIsPower_OldCoins = player:GetNumCoins()
    end
end
function _Stillbirth:MoneyLuck_UpdateStats(player, cacheFlag) --StatsUpdate Code
    local player = Isaac.GetPlayer(0)
    if ( player:HasCollectible( Items.moneyLuck_i ) ) then
        if cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck  = player.Luck + (player:GetNumCoins()*0.05048)
        end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.MoneyLuck_obj);
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.MoneyLuck_UpdateStats);

--[[
Active item: "Beer"
-Drazeb-
--]]
function _Stillbirth:use_beer()
    local p = Isaac.GetPlayer(0);
    local entities = Isaac.GetRoomEntities( )
    local game = Game()
	SFXManager():Play(19, 1.0, 1, false, 1)
	GiantBooks.dadsbeer:LoadGraphics()
	GiantBooks.dadsbeer:Play("Shake", true)
	FreezeGame(35)
    for i = 1, #entities do
        if entities[i]:IsActiveEnemy() then
        	if entities[i]:IsBoss() then
		        -- Ajout confusion et dmg aux ennemis --
		        entities[i]:AddConfusion( EntityRef(p), 100, false )
		        entities[i]:TakeDamage(10.0,0,EntityRef(p),1)
		    else
		    	entities[i]:AddEntityFlags(1<<9)
		        entities[i]:TakeDamage(10.0,0,EntityRef(p),1)
		   	end
        end
    end
    -- Assombrissement la salle --
    game:Darken(1.0,100)
    return true
end
_Stillbirth:AddCallback( ModCallbacks.MC_USE_ITEM, _Stillbirth.use_beer, Items.Beer_i );

--[[
Passive item: "Brave Shoe"
-xahos-
--]]
function _Stillbirth:braveShoeCache(player, cacheFlag)
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(Items.brave_shoe_i) then
        if (cacheFlag == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed + 0.2;
        end
    end
end
-- NOTE(krayz): ModCallbacks.MC_ENTITY_TAKE_DMG moved in "mc_entity_take_dmg.lua" file
--~ _Stillbirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.braveShoeDamage, EntityType.ENTITY_PLAYER)
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.braveShoeCache)

--[[
Passive item : Technology 0 : un cercle qui s'agrandit quand on tire et qui suit isaac un peu comme tech X
-Dogeek & Krayz-
--]]
local function Tech_0_fire_lazer(player, radius) -- Shoot a TechX lazer centred on player with no velocity
    local tech0_lazer = player:FireTechXLaser(player.Position, Vector(0,0), radius)
    tech0_lazer:SetTimeout(3)
    return tech0_lazer
end

function _Stillbirth:tech0_update()
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(Items.tech0_i) then
        local tech0_lazer = nil
        if g_vars.tech0_oldFrame <= 0 then
            g_vars.tech0_oldFrame = player.FrameCount
        end
        if IsShooting(player) and (player.FrameCount - g_vars.tech0_oldFrame) > player.MaxFireDelay then
            g_vars.tech0_oldFrame = player.FrameCount
            tech0_lazer = Tech_0_fire_lazer( player, GetRange(player) )
            tech0_lazer.Radius = tech0_lazer.Radius + GetRange(player) * g_vars.tech0_n
            tech0_lazer:SetMultidimensionalTouched(1)
            g_vars.tech0_n = g_vars.tech0_n + player.ShotSpeed
            g_vars.tech0_oldFrame = player.FrameCount
        end
        if tech0_lazer and tech0_lazer.Radius <= GetRange(player) * 11.5 then
            g_vars.tech0_n = 1.0
        end
    end
end
_Stillbirth:AddCallback( ModCallbacks.MC_POST_UPDATE, _Stillbirth.tech0_update);

--[[
Passive item : Hot Pizza Slice : Damage up, size up et 1 soul heart
-Dogeek-
--]]
function _Stillbirth:hot_pizza_slice_cacheUpdate(player, cacheFlag)
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(Items.hot_pizza_slice_i) then
        if (cacheFlag == CacheFlag.CACHE_DAMAGE) then
            player.Damage = DamageToSet(player, 1, 1);
            if not g_vars.hot_pizza_slice_HpUp_Done then
                player.SpriteScale = player.SpriteScale * 1.2;
                player:AddSoulHearts(2);
                g_vars.hot_pizza_slice_HpUp_Done = true
            end
        end
    end
end
_Stillbirth:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.hot_pizza_slice_cacheUpdate);

--[[
Active item : Golden Idol : Donne un coeur bleugoldé
-Dogeek-
-K
--]]
function _Stillbirth:GoldenIdol_onUse()
    local player = Isaac.GetPlayer(0)
    SFXManager():Play(32, 1.0, 1, false, 1.0)
    GiantBooks.goldenidol:LoadGraphics()
    GiantBooks.goldenidol:Play("Appear", true)
    FreezeGame(34)
    if (not player:HasCollectible(Items.solomon_i)) or ((player:GetHearts()+player:GetSoulHearts())<12) then
    	player:AddSoulHearts(2);
    end
    if player:CanPickGoldenHearts() then
    	player:AddGoldenHearts(1);
    else --spawns 5 to 8 random coins around the player pennies 80%, nickel 10%, dimes 5%, lucky 5%
    	local rand = math.random(5, 8)
    	local lower = -math.floor(rand/2)
    	local upper = lower + rand
    	for i=lower, upper do
    		local rand = math.random(100)
    		if rand<80 then
    			rand = 1
    		elseif rand>=80 and rand <90 then
    			rand = 2
    		elseif rand>=90 and rand <95 then
    			rand = 3
    		else
    			rand = 5
    		end
    		local x = i%2
    		local y = math.floor(i/2)
    		if x==0 and y == 0 then
    			x = 1
    			y = 1
    		end
    		local pos = player.Position + Vector(x*32, y*32)
    		Isaac.Spawn(5, 20, rand, pos, Vector(0,0), player)
    	end
    end
    return true
end
_Stillbirth:AddCallback(ModCallbacks.MC_USE_ITEM, _Stillbirth.GoldenIdol_onUse, Items.golden_idol_i);

--[[
Active item : Medusa's Head
-Azqswx-
--rework by : Dogeek
--]]
function _Stillbirth:medusaHead_use()
	local entities = Isaac.GetRoomEntities();
	local player = Isaac.GetPlayer(0);
	local range = math.abs(GetRange(player) * 12.5);
	SFXManager():Play(18, 1.0, 1, false, 1.0)
	GiantBooks.medusa:LoadGraphics()
	GiantBooks.medusa:Play("Appear", true)
	FreezeGame(34)
	--g_vars.framecount_stop = Game():GetFrameCount() + duration
	for i = 1, #entities do
		local e = entities[i]
		if entities[i]:IsActiveEnemy(false) then        --Test if entity is ennemy NPC
			local distance = getDistance(player.Position, e.Position)      --get distance between NPC and Isaac
			if distance < range  then
				if not e:IsBoss() then                             --if NPC is a boss, then freeze for 5 seconds else, freeze indefinitely
                    if isColinear(e.Position-player.Position, player:GetRecentMovementVector(), 0.5) then
                        e:AddEntityFlags(1<<5)                           -- "1<<5" = Flag for freezing entity
                        e:SetColor(Color(0.25,0.25,0.25,1,39,39,39),1000000,99,false,true)        --Change color
                    end
                else
                    if isColinear(player.Position-e.Position, player:GetRecentMovementVector(), 0.5) then
                        e:AddFreeze(EntityRef(player), 150+34)                   --Add Freeze(5sec)
                        e:SetColor(Color(0.25,0.25,0.25,1,39,39,39),150,99,false,true)        --Change color
                    end
                end
            end
        end
        --if not e:HasEntityFlags(1<<5) then
        --	e:AddFreeze(EntityRef(player), 34)
        --end
    end
    return true
end
_Stillbirth:AddCallback( ModCallbacks.MC_USE_ITEM, _Stillbirth.medusaHead_use, Items.medusa_head_i );

--[[
Passive Item : Blind Pact : Missing No de DD donne un passif de DD aleatoire a chaque étage.
-Dogeek-
--]]

function _Stillbirth:blindPactUpdate()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(Items.blind_Pact_i) then
        local currentStage = Game():GetLevel():GetStage()
        if g_vars.blindPact_previousStage ~= currentStage then
            local rand = math.random(#devilPoolPassive)
            g_vars.blindPact_pickedItem = devilPoolPassive[rand]
            if not player:HasCollectible(g_vars.blindPact_pickedItem) then
            	player:AddCollectible(g_vars.blindPact_pickedItem, 0, true)
            	g_vars.blindPact_previousStage = currentStage
			end
            if (g_vars.blindPact_previousItem ~= 0) and player:HasCollectible( g_vars.blindPact_previousItem ) then
                player:RemoveCollectible( g_vars.blindPact_previousItem )
            end
        else
            g_vars.blindPact_previousItem  = g_vars.blindPact_pickedItem
        end
    end
end
_Stillbirth:AddCallback( ModCallbacks.MC_POST_UPDATE, _Stillbirth.blindPactUpdate);

--[[
Passive Item: Solomon
-- BUG?: If player already has an item given by this, delete the costume and didnt add it again
Réduit la barre d'HP à 6 coeurs max mais gros boost de stats
-Dogeek
-Azqswx
--]]

function _Stillbirth:SolomonCacheUp(player, cacheFlag) --Krayz
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(Items.solomon_i) then
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + 1.5
            player.Damage = player.Damage * 1.2
        end
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay - 3
        end
        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + 0.6
        end
        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + 0.3
        end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.SolomonCacheUp)

function _Stillbirth:SolomonUpdate()
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(Items.solomon_i) then
        local entities = Isaac.GetRoomEntities()
        local redHearts = player:GetMaxHearts()
        local soulHearts = player:GetSoulHearts()
        if not IsFullBlackHearts(player) then
            for i = 1, #entities do
                local e = entities[i]
                if e.Type == 5 and e.Variant == 10 and e.SubType == HeartSubType.HEART_BLACK then
                    e.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
                end
            end
        end
        if (redHearts+soulHearts > 12) then
            if (soulHearts ~= 0) then
                player:AddSoulHearts(-1)
                for i = 1, #entities do
                    local e = entities[i]
                    if e.Type == 5 and e.Variant == 10 and (e.SubType == HeartSubType.HEART_SOUL or e.SubType == HeartSubType.HEART_HALF_SOUL or e.SubType == HeartSubType.HEART_BLACK) then
                        BounceHearts(e)
                    end
                end
            else
               player:AddMaxHearts(-2, false)
            end
        elseif (redHearts+soulHearts)<12 then
        	for i = 1, #entities do
                local e = entities[i]
                if e.Type == 5 and e.Variant == 10 and (e.SubType == HeartSubType.HEART_SOUL or e.SubType == HeartSubType.HEART_HALF_SOUL) then
                    e.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
                end
            end
        elseif (redHearts+soulHearts)==12 then
        	for i = 1, #entities do
                local e = entities[i]
                if e.Type == 5 and e.Variant == 10 then
		            if (e.SubType == HeartSubType.HEART_SOUL or e.SubType == HeartSubType.HEART_HALF_SOUL) then
		                BounceHearts(e)
		            elseif (e.SubType == HeartSubType.HEART_BLACK and IsFullBlackHearts(player)) then
		            	BounceHearts(e)
		            end
                end
            end
        end
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.SolomonUpdate)

--[[
Cataract : Epiphora pour le dommage et le tear delay
--Dogeek
-k
--]]
local cataract_numberOfTearsShot = 0
local cataract_previousDirection = -1
local cataract_baseDamage = 0
local cataract_baseShotSpeed = 0
local cataract_restored_values = -999
local cataract_oldFrame = -1

function _Stillbirth:cataract_EvCache(player, cacheFlag)
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(Items.cataract_i) then
        if IsShooting(player) then
			if not cataract_restored_values then
				cataract_numberOfTearsShot = 0
				player.Damage = cataract_baseDamage
				player.ShotSpeed = cataract_baseShotSpeed
				cataract_restored_values = true
				cataract_previousDirection = player:GetFireDirection()
			else
				cataract_restored_values = -99
				if cacheFlag == CacheFlag.CACHE_DAMAGE then
					player.Damage = player.Damage + cataract_numberOfTearsShot
				end
				if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
					player.ShotSpeed = player.ShotSpeed - (player.ShotSpeed*0.12) * cataract_numberOfTearsShot
				end
			end
        end
        if not cataract_restored_values then
            cataract_numberOfTearsShot = 0
            player.Damage = cataract_baseDamage
            player.ShotSpeed = cataract_baseShotSpeed
            cataract_restored_values = true
        end
    end
end

local function cataract_restore_val(player)
	cataract_oldFrame = player.FrameCount
	cataract_restored_values = false
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
	player:EvaluateItems()
end

function _Stillbirth:cataract_PostUpdate()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(Items.cataract_i) then
        dbz = cataract_numberOfTearsShot
        if cataract_restored_values == -999 then
            cataract_baseDamage = player.Damage
            cataract_baseShotSpeed = player.ShotSpeed
            cataract_restored_values = -99
        end
        if IsShooting(player) then
            if (player.FrameCount - cataract_oldFrame) < 0 then
                cataract_oldFrame = player.FrameCount
            end
            if player:GetFireDirection() ~= cataract_previousDirection then
				cataract_restore_val(player)
            elseif (player.FrameCount - cataract_oldFrame) >= Secondes30fps(3.2-(cataract_numberOfTearsShot*0.3)) then
                if cataract_numberOfTearsShot < 3 then
                    cataract_numberOfTearsShot = cataract_numberOfTearsShot + 1
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
                    player:EvaluateItems()
                end
                cataract_oldFrame = player.FrameCount
            end
        else
            if cataract_restored_values == -99 then
				cataract_restore_val(player)
            end
            cataract_oldFrame = player.FrameCount
            cataract_baseDamage = player.Damage
            cataract_baseShotSpeed = player.ShotSpeed
        end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.cataract_EvCache)
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.cataract_PostUpdate)

--[[
-Krayz
Item Passif : Bubble's Head
Tire de temps a autres une larme feuille qui stopwatch les ennemis
--]]

function _Stillbirth:BubblesHead_Update()
    local player = Isaac.GetPlayer(0)
    local entities = Isaac.GetRoomEntities()

    if player:HasCollectible(Items.BubblesHead_i) and player:HasWeaponType(1) then
        if (player.FrameCount - g_vars.BubblesHead_oldFrame) <= 0 then
            g_vars.BubblesHead_oldFrame = player.FrameCount
        end
        if IsShooting( player ) and (player.FrameCount - g_vars.BubblesHead_oldFrame) > player.MaxFireDelay then
            local LuckModifier = ( player.Luck * 0.040 )
            if LuckModifier > 0.4 then LuckModifier = 0.4 end
            local rand = math.random() + LuckModifier
            local v = Vector( math.abs( player:GetLastDirection().X ), math.abs( player:GetLastDirection().Y ) )
            g_vars.BubblesHead_oldFrame = player.FrameCount
            g_vars.BubblesHead_ShootedTears = g_vars.BubblesHead_ShootedTears + 1
            if (v.X == 1 or v.Y == 1) and rand > 0.923 and g_vars.BubblesHead_ShootedTears > 4 then
                local tear = GetClosestTear( entities, player, 2, CustomEntities.TearLeaf_Variant )
                local vel = Vector(7.5*player.ShotSpeed,7.5*player.ShotSpeed)
                if tear then
					tear = tear:ToTear()
					tear:ChangeVariant( CustomEntities.TearLeaf_Variant )
					tear:GetSprite():Load("gfx/002.150_tear_leaf.anm2", true)
					tear:GetSprite():Play("Stone1Move", true)
					g_vars.BubblesHead_ShootedTears = 0
                end
            end
        end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.BubblesHead_Update)

--------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- NOTE(krayz): ModCallbacks.MC_ENTITY_TAKE_DMG moved in "mc_entity_take_dmg.lua" file
-- and all tearleaf mechanics related code

-- _Stillbirth:AddCallback( ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.TearLeaf_MobSlowing );
-- _Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.TearLeaf_BossTimer)

--[[
Passive item: "First Blood"
-Azqswx-
--]]

function _Stillbirth:newRoomWithEnemies()
    local room = Game():GetRoom()
    if not room:IsClear() then
        g_vars.FirstBlood_Done = true;
    end
end

function _Stillbirth:firstBloodEffect()
    local player = Isaac.GetPlayer(0);
    local playerDamage = player.Damage;
    local entities = Isaac.GetRoomEntities();
    if g_vars.FirstBlood_Done and player:HasCollectible(Items.first_blood_i) then
        for i = 1, #entities do
            if (entities[i].Type == EntityType.ENTITY_TEAR) and (entities[i]:GetLastParent().Type == player.Type) then
            	local e = entities[i]:ToTear();
                --entities[i]:ToTear():SetDeadEyeIntensity(10.0)
                e.CollisionDamage  = playerDamage * 10;
                e.Scale = 1+playerDamage*0.5;
                if entities[i].FrameCount <= 1 then
                    e:ChangeVariant(1);
                end
                g_vars.FirstBlood_Done = false;
            end
        end
    end
end

_Stillbirth:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, _Stillbirth.newRoomWithEnemies)
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.firstBloodEffect)

--[[
Blank Tissue : supprime toute les larmes de la salle
--Dogeek
--]]
local blankTissue_MAXCHARGE = 7.5*8 -- 30 fps * nb_of_seconds
local blankTissue_charge = blankTissue_MAXCHARGE
function _Stillbirth:BlankTissueRecharge()
	player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.blankTissues_i) then
		if blankTissue_charge<blankTissue_MAXCHARGE and Game():GetFrameCount()%4 == 0 then
			blankTissue_charge = blankTissue_charge+1
			player:SetActiveCharge(blankTissue_charge)
			if SFXManager():IsPlaying(SoundEffect.SOUND_BEEP) then SFXManager():Stop(SoundEffect.SOUND_BEEP) end
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.BlankTissueRecharge)

function _Stillbirth:OnBlankTissueUse()
    local player = Isaac.GetPlayer(0)
    blankTissue_charge = 0
    local entities = Isaac.GetRoomEntities()
    if not SFXManager():IsPlaying(6) then
    	SFXManager():Play(6, 1.0, 1, false, 1.0)
    end
    for i=1, #entities do
    	if entities[i].Type == EntityType.ENTITY_PROJECTILE then
    		entities[i]:Remove()
    	end
    end
    return true
end
_Stillbirth:AddCallback(ModCallbacks.MC_USE_ITEM, _Stillbirth.OnBlankTissueUse, Items.blankTissues_i)

--[[
Item Passive : Choranaptyxic : Stats basées sur grande ou petite salle. Salle neutre ne modifie pas
--Dogeek
Tear rate + speed petite
Range + damage dans les grandes
--]]

local chora_bdmg = 0
local chora_brange = 0
local chora_bspeed = 0
local chora_btears = 1
local chora_lastShape = 0

function _Stillbirth:ChoranaptyxicNewRoom()
	local player = Isaac.GetPlayer(0)
	if g_vars.chora_hasCostume then
		player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/choranaptyxicblue.anm2"))
		player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/choranaptyxicred.anm2"))
		g_vars.chora_hasCostume = false
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, _Stillbirth.ChoranaptyxicNewRoom)

function _Stillbirth:ChoranaptyxicCache(player, cacheFlag)
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(Items.choranaptyxic_i) then
        if cacheFlag==CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + chora_bdmg
        end
           if cacheFlag==CacheFlag.CACHE_RANGE then
            player.TearHeight = player.TearHeight + chora_brange
        end
        if cacheFlag==CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + chora_bspeed
        end
        if cacheFlag==CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay*chora_btears
        end
    end
end

function _Stillbirth:ChoranaptyxicUpdate()
    local player = Isaac.GetPlayer(0)
    local entities = Isaac.GetRoomEntities()
    local roomShape = Game():GetRoom():GetRoomShape()
    if player:HasCollectible(Items.choranaptyxic_i) then
		if roomShape ~= chora_lastShape then
			if roomShape == RoomShape.ROOMSHAPE_IH or roomShape == RoomShape.ROOMSHAPE_IV or roomShape == RoomShape.ROOMSHAPE_IIV or roomShape == RoomShape.ROOMSHAPE_IIH then
				chora_bdmg = 0
				chora_brange = 0
				chora_bspeed = 0.3
				chora_btears = 0.7
				if not g_vars.chora_hasCostume then
					player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/choranaptyxicblue.anm2"))
					g_vars.chora_hasCostume = true
				end
			elseif roomShape == RoomShape.ROOMSHAPE_1x2 or roomShape == RoomShape.ROOMSHAPE_2x1 or roomShape == RoomShape.ROOMSHAPE_2x2 or roomShape == RoomShape.ROOMSHAPE_LTL or roomShape == RoomShape.ROOMSHAPE_LTR or roomShape == RoomShape.ROOMSHAPE_LBL or roomShape == RoomShape.ROOMSHAPE_LBR then
				chora_bdmg = 2
				chora_brange = -10
				chora_bspeed = 0
				chora_btears = 1
				if not g_vars.chora_hasCostume then
					player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/choranaptyxicred.anm2"))
					g_vars.chora_hasCostume = true
				end
			else
				chora_bdmg = 0
				chora_brange = 0
				chora_bspeed = 0
				chora_btears = 1
				if g_vars.chora_hasCostume then
					player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/choranaptyxicblue.anm2"))
					player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/choranaptyxicred.anm2"))
					g_vars.chora_hasCostume = false
				end
			end
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:AddCacheFlags(CacheFlag.CACHE_RANGE)
			player:EvaluateItems()
		end
		chora_lastShape = roomShape
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.ChoranaptyxicUpdate)
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.ChoranaptyxicCache)

--[[
Active item : Magic Mirror
-Azqswx-
--]]
function _Stillbirth:use_magic_mirror()
    local player = Isaac.GetPlayer(0);
    --local level = Game():GetLevel()
    --Game():StartRoomTransition(level:GetStartingRoomIndex, Direction.RIGHT, animation)
    player:UseCard(1);
	return true
end
_Stillbirth:AddCallback( ModCallbacks.MC_USE_ITEM, _Stillbirth.use_magic_mirror, Items.magic_mirror_i );

function _Stillbirth:removeTheFoolSound()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.magic_mirror_i) and player:NeedsCharge() then--and SFXManager():IsPlaying(SoundEffect.SOUND_FOOL) then
		SFXManager():Stop(SoundEffect.SOUND_FOOL)
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.removeTheFoolSound)

--[[
Active item : Encyclopedia
-Azqswx-
--]]
function _Stillbirth:use_encyclopedia()
    local player = Isaac.GetPlayer(0);
    local rng = math.ceil(math.random(1,#libraryPool));
    GiantBooks.encyclopedia:LoadGraphics()
    GiantBooks.encyclopedia:Play("Appear", true)
    FreezeGame(34)
    player:UseActiveItem(libraryPool[rng],true,false,false,false)
	return true
end
_Stillbirth:AddCallback( ModCallbacks.MC_USE_ITEM, _Stillbirth.use_encyclopedia, Items.encyclopedia_i );

--[[
Active Item: "ExplosiveBanana"
-Krayz-
https://www.youtube.com/watch?v=LH5ay10RTGY
Lance une banane de type mine explosive, laisse du creep jaune qui ralentit
Slow only apply to ground enemy
--]]
-- this item don't need save
local BanaV = 	{
                            ExBanana = nil,
                            ExBananaCreep = nil,
                            ExBananaCreep2 = nil,
                            ExBananaSprite  = 0,
                            ExBanana_frame = 0,
                            ExBananaSpawned = false,
                            ExBananaActive = false,
                            CreepSpawn = false,
                            Ready = false,
                            costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_exbanana.anm2")
                        }

local function ExBanana_resetVars()
    BanaV.ExBanana = nil
    BanaV.ExBananaCreep = nil
    BanaV.ExBananaCreep2 = nil
    BanaV.ExBanana_frame = 0
    BanaV.ExBananaSpawned = false
    BanaV.ExBananaActive = false
    BanaV.CreepSpawn = false
    BanaV.Ready = false
    Isaac.GetPlayer(0):TryRemoveNullCostume(BanaV.costume)
end

function _Stillbirth:ExBanana_use()
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(Items.ExBanana_i) and not BanaV.Ready and not BanaV.ExBananaSpawned then
        BanaV.Ready = true
        player:AddNullCostume(BanaV.costume)
        return false
    elseif BanaV.Ready  then
        BanaV.Ready = false
        player:TryRemoveNullCostume(BanaV.costume)
        return false
    end
end
_Stillbirth:AddCallback( ModCallbacks.MC_USE_ITEM, _Stillbirth.ExBanana_use, Items.ExBanana_i );

local function ExBanana_SkipToEndMov(condition)
	if condition then BanaV.ExBanana_frame = 39 end
end

function _Stillbirth:ExBanana_Mine()
    local player = Isaac.GetPlayer(0)

    if ( player:HasCollectible(Items.ExBanana_i) ) then
        local entities = Isaac.GetRoomEntities()
        local room = Game():GetRoom()
        if room:GetFrameCount() == 1 then ExBanana_resetVars() end -- reset vars every room
        if BanaV.Ready and IsShooting(player) then
            player:TryRemoveNullCostume(BanaV.costume)
            Velocity = Vector( ((player:GetLastDirection().X*8) + (player:GetVelocityBeforeUpdate().X*1.1)), (( player:GetLastDirection().Y*8 ) + (player:GetVelocityBeforeUpdate().Y*1.1)) )
            BanaV.ExBanana = Game():Spawn(CustomEntities.BananaEntity, CustomEntities.BananaEntity_Variant, player.Position:__sub( Vector(0, -5) ), Vector(0,0), player, 0, 0) -- Explosive Banana
            BanaV.ExBanana.Friction = 1
            BanaV.ExBanana:ClearEntityFlags( 1<<2 )
            BanaV.ExBanana:AddEntityFlags( 1<<5 )
            BanaV.ExBanana:AddVelocity( Velocity:__mul(1.15) )
            BanaV.ExBanana:ClearEntityFlags( 1<<5 )
            BanaV.ExBanana:AddEntityFlags( 1<<0|1<<4|1<<15|1<<26|1<<29|1<<30 )
            BanaV.ExBananaSprite = BanaV.ExBanana:GetSprite();
            BanaV.ExBanana.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
            BanaV.ExBanana.GridCollisionClass = 6 -- 5 = allgrid ent 6 = nopits ; 3 = wall only
            BanaV.ExBananaSprite:Play("Idle", true);
            BanaV.ExBanana.RenderZOffset  = 5
            BanaV.ExBananaSpawned = true
            BanaV.ExBananaActive = false
            BanaV.Ready = false
        elseif BanaV.ExBananaSpawned and not BanaV.ExBananaActive then
            BanaV.ExBanana_frame = BanaV.ExBanana_frame + 1
            if BanaV.ExBanana:CollidesWithGrid() then
                BanaV.ExBanana:MultiplyFriction( 0.3 )
				ExBanana_SkipToEndMov(IsEntityInPit(BanaV.ExBanana)) -- skip to endMov code
            end
            if BanaV.ExBanana_frame < 18 then
                local amp = inQuad( BanaV.ExBanana_frame * 0.60, 1, 9-1, 9 )
                db_a = amp
                BanaV.ExBanana.PositionOffset = Vector( 0, amp ) -- Zou
            elseif BanaV.ExBanana_frame < 40 then
				if BanaV.ExBanana_frame < 39 then ExBanana_SkipToEndMov(math.abs(BanaV.ExBanana.Velocity.X) + math.abs(BanaV.ExBanana.Velocity.Y) < 0.02) end -- skip to endMov code
                BanaV.ExBanana.PositionOffset = Vector( 0, 14 ) -- EndMovOnTheFloor
                BanaV.ExBanana:MultiplyFriction( 0.05 ) -- StopMoving
                if not BanaV.CreepSpawn then
                    BanaV.ExBananaCreep2 = Isaac.Spawn( 1000, 24, 0, BanaV.ExBanana.Position, Vector(0, 0), player ) -- ExBanana Creep2 Yl
                    BanaV.ExBananaCreep2:AddEntityFlags( 1<<0|1<<4|1<<15|1<<26|1<<29|1<<30 )
                    BanaV.ExBananaCreep2:SetColor( Color( 1.0, 1.0, 0.0, 0.0, 255, 255, 0 ) , 9999, 9999, false, false )
                    BanaV.ExBananaCreep2.SpriteScale = BanaV.ExBananaCreep2.SpriteScale * 6.0
                    BanaV.ExBananaCreep2:ToEffect():SetTimeout(9999)
					if not IsEntityInPit(BanaV.ExBanana) then
						SFXManager():Play(445, 1.9, 0, false, 0.45)
					end
                    BanaV.CreepSpawn = true
                end
				dbz = IsEntityInPit(BanaV.ExBanana)
            else
				local a = (BanaV.ExBanana_frame - 40)
				if not IsEntityInPit(BanaV.ExBanana) then
					if BanaV.ExBanana_frame <= 70 then
						BanaV.ExBananaCreep2:SetColor( Color( 1.0, 1.0, 0.0, a/100 , 255, 255, 0 ) , 9999, 9999, false, false ) -- creep
						BanaV.ExBanana:SetColor( Color( (a/200)+0.15, 0.15, 0.0, 1.0, 0, 0, 0 ) , 9999, 9999, false, false ) -- banana
						if a == 20 then
							BanaV.ExBananaCreep = Isaac.Spawn( 1000, 44, 0, BanaV.ExBanana.Position, Vector(0, 0), player ) -- ExBanana Creep Sl
							BanaV.ExBananaCreep:AddEntityFlags( 1<<0|1<<4|1<<15|1<<26|1<<29|1<<30 )
							BanaV.ExBananaCreep:SetColor( Color( 0.0, 0.0, 0.0, 0.0, 0, 0, 0 ) , 9999, 9999, false, false )
							BanaV.ExBananaCreep.SpriteScale = BanaV.ExBananaCreep.SpriteScale * 5.0
							BanaV.ExBananaCreep:ToEffect():SetTimeout(9999)
						end
					else
						if not BanaV.ExBananaSprite:IsPlaying( "Float" ) then
							BanaV.ExBananaSprite:Play( "Float", true )
							SFXManager():Play(229, 0.5, 0, false, 2.5)
						end
						BanaV.ExBananaCreep.Position = BanaV.ExBanana.Position
						BanaV.ExBananaCreep2.Position = BanaV.ExBanana.Position
						BanaV.ExBananaActive = true -- Start damage/effect
					end
				else -- Fall in pit
					-- SortOf fancy falling sound effects
					if a == 1 then
						SFXManager():Play(242, 0.5, 0, false, 6.0)
					else
						SFXManager():AdjustPitch(242, (6.0-a/7) >= 0 and (6.0-a/7) or 0)
						SFXManager():AdjustVolume(242, (0.5 - a/70) >= 0 and (0.5 - a/70) or 0)
					end
					if a <= 40 then
						if BanaV.CreepSpawn then
							BanaV.ExBananaCreep2:Remove()
							BanaV.CreepSpawn = false
						end
						BanaV.ExBanana.SpriteScale = BanaV.ExBanana.SpriteScale * (1.0-a/60)
						local c = a/30 <= 1 and a/30 or 1
						BanaV.ExBanana:SetColor( Color( 0.15+c, 0.15+c, c, 1.0-c, 0, 0, 0 ) , 9999, 9999, false, false ) -- banana
--~ 						BanaV.ExBanana.PositionOffset = Vector( 0, 14+a/20 ) -- Add even more SortOfFallingly anm
					elseif a == 41 then
						SFXManager():Play(267, 0.3, 0, false, 0.2)
						if BanaV.ExBanana then
							BanaV.ExBanana:Remove()
						end
						ExBanana_resetVars()
					end
				end
			end
        elseif BanaV.ExBananaSpawned and BanaV.ExBananaActive then
            local f = player.FrameCount
            local rg = (function() if f&3==0 then return math.abs(math.sin(f)) end end )() -- blink
            if rg then
                BanaV.ExBanana:SetColor( Color( rg , rg, 0.0, 1.0, 55, 0, 0 ) , 9999, 9999, false, false ) -- banana blink
            end
            BanaV.ExBananaCreep2:SetColor( Color( 1.0, 1.0, 0.0, 0.38 , 255, 255, 0 ) , 9999, 9999, false, false ) -- creep
            local DmgRad = 0
            for i = 1, #entities do
                if (player.FrameCount&7 == 0 and BanaV.ExBanana and entities[i]:IsVulnerableEnemy() ) then
                    if ( entities[i]:ToNPC():IsBoss() ) then
                        DmgRad = 100
                    elseif ( entities[i]:ToNPC():IsChampion() ) then
                        DmgRad = 80
                    else
                        DmgRad = 68
                    end
                    local bval =  math.abs( entities[i].Position.X - BanaV.ExBanana.Position.X ) + math.abs( entities[i].Position.Y - BanaV.ExBanana.Position.Y )
                    if bval <= DmgRad  then
                        Game():BombExplosionEffects( BanaV.ExBanana.Position, 30.0, player:GetBombFlags(), Color( 0.4, 0.4, 0.4, 1.0 , 100, 100, 0 ), entities[i], 1.5, false, true)
                        entities[i]:AddConfusion( EntityRef(player), 60, true )
                        BanaV.ExBananaCreep:ToEffect():SetTimeout(1)
                        BanaV.ExBananaCreep2:ToEffect():SetTimeout(1)
                        BanaV.ExBanana:Remove()
                        ExBanana_resetVars()
                    end
                end
            end
        end
    end
end
_Stillbirth:AddCallback( ModCallbacks.MC_POST_UPDATE, _Stillbirth.ExBanana_Mine )

--[[
Item : Oddit -Ottid en fait
Type : Passive
By : Dogeek
Date : 2017-03-06
TODO : superbum ?
]]--

function addMissingItem(pool)
	local player = Isaac.GetPlayer(0)
	local choice = {}
	for i=1, #pool do
		if not player:HasCollectible(pool[i]) and pool[i] ~= 81 then
			table.insert(choice, pool[i])
		end
		for i=1, #ItemPools.ACTIVES do
			if not has_value(ItemPools.ACTIVES, pool[i]) then
				table.insert(choice, pool[i])
			end
		end
	end
	local currentActive = player:GetActiveItem()
	if currentActive ~= nil then
		local currentCharge = player:GetActiveCharge()
	end
	player:AddCollectible(choice[1], 0, false)
	player:RemoveCollectible(choice[1])
	if currentActive ~= nil then
		if currentCharge ~= nil then
			player:AddCollectible(currentActive, currentCharge, false)
		else
			player:AddCollectible(currentActive, 6, false)
		end
	end
end

function _Stillbirth:OttidUpdate()
	local player = Isaac.GetPlayer(0)
	if (g_vars.ottid_init_check or  player:GetCollectibleCount()>g_vars.ottid_collectible_count) then --player:HasCollectible(Items.ottid_i) and --check unnecessary
		if not g_vars.ottid_pillGiven then
			--player:UsePill(PillEffect.PILLEFFECT_PUBERTY, PillColor.PILL_NULL)
			g_vars.ottid_pillGiven = true
		end
		g_vars.ottid_init_check = false
		g_vars.ottid_collectible_count = player:GetCollectibleCount()
		if hasTransfo(guppyPool, 3) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_GUPPY)
			addMissingItem(guppyPool)
		elseif hasTransfo(beezlebubPool, 3) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES)
			addMissingItem(beezlebubPool)
		elseif hasTransfo(funGuyPool, 3) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_MUSHROOM) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_MUSHROOM)
			addMissingItem(funGuyPool)
		elseif hasTransfo(seraphimPool, 3) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_ANGEL) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_ANGEL)
			addMissingItem(seraphimPool)
		elseif hasTransfo(bobPool, 3) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_BOB) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_BOB)
			addMissingItem(bobPool)
		elseif hasTransfo(spunPool, 3) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_DRUGS) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_DRUGS)
			addMissingItem(spunPool)
		elseif hasTransfo(momPool, 3) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_MOM) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_MOM)
			addMissingItem(momPool)
		elseif hasTransfo(conjoinedPool, 3) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_BABY) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_BABY)
			addMissingItem(conjoinedPool)
		elseif hasTransfo(leviathanPool, 3) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_EVIL_ANGEL) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_EVIL_ANGEL)
			addMissingItem(leviathanPool)
		elseif hasTransfo(poopPool, 3) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_POOP) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_POOP)
			addMissingItem(poopPool)
		elseif hasTransfo(bookWormPool, 3) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_BOOK_WORM)
			addMissingItem(bookWormPool)
		elseif hasTransfo(spiderBabyPool, 3) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_SPIDERBABY) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_SPIDERBABY)
			addMissingItem(spiderBabyPool)
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.OttidUpdate)

--[[ http://pastebin.com/e8tSm91i pools
Item : Items de boss
Type : passives
By : Dogeek psq Shisheyu m'a troll
Date : 2017-03-10
]]--

-----------------------------
-- CACHE UPDATE
-----------------------------

function _Stillbirth:PepperSprayCache(player, cacheFlag)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.pepper_spray_i) then
		for i=1, g_vars.pepper_spray_cnt do
			if cacheFlag == CacheFlag.CACHE_FIREDELAY and player.MaxFireDelay > 7 then
				player.MaxFireDelay = player.MaxFireDelay - 3
			elseif cacheFlag == CacheFlag.CACHE_FIREDELAY and player.MaxFireDelay == 7 then
				player.MaxFireDelay = player.MaxFireDelay - 2
			elseif cacheFlag == CacheFlag.CACHE_FIREDELAY and player.MaxFireDelay == 6 then
				player.MaxFireDelay = player.MaxFireDelay - 1
			end
		end
		if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed - 0.2 * g_vars.pepper_spray_cnt
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.PepperSprayCache)

function _Stillbirth:RattleCache(player, cacheFlag)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.rattle_i) then
		for i=1, g_vars.rattle_cnt do
			if cacheFlag == CacheFlag.CACHE_FIREDELAY and player.MaxFireDelay > 6 then
				player.MaxFireDelay = player.MaxFireDelay - 2
			elseif cacheFlag == CacheFlag.CACHE_FIREDELAY and player.MaxFireDelay == 6 then
				player.MaxFireDelay = player.MaxFireDelay - 1
			end
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.RattleCache)

function _Stillbirth:SpinachCache(player, cacheFlag)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.spinach_i) then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed - 0.2*g_vars.spinach_cnt
		end
		if cacheFlag == CacheFlag.CACHE_RANGE then
			player.TearHeight = player.TearHeight + 5*g_vars.spinach_cnt
		end
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = DamageToSet(player, 1*g_vars.spinach_cnt, 1)
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.SpinachCache)

function _Stillbirth:AppetizerCache(player, cacheFlag)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.appetizer_i) then
		for i=1, g_vars.appetizer_cnt do
			if cacheFlag == CacheFlag.CACHE_FIREDELAY and player.MaxFireDelay > 5 then
				player.MaxFireDelay = player.MaxFireDelay - 1
			end
		end
		if not g_vars.appetizer_HP_UP_GIVEN then
			player:AddMaxHearts(2)
			player:AddHearts(2)
			g_vars.appetizer_HP_UP_GIVEN = true
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.AppetizerCache)

function _Stillbirth:MomsCakeCache(player, cacheFlag)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.momscake_i) then
		if cacheFlag == CacheFlag.CACHE_RANGE then
			player.TearHeight = player.TearHeight - 5.25*g_vars.momscake_cnt
		end
		if not g_vars.momscake_HP_UP_GIVEN then
			player:AddMaxHearts(2)
			player:AddHearts(2)
			g_vars.momscake_HP_UP_GIVEN = true
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.MomsCakeCache)

function _Stillbirth:RabbitsFootCache(player, cacheFlag)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.rabbitsFoot_i) then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + 0.2*g_vars.rabbitsfoot_cnt
		end
		if cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck + 1*g_vars.rabbitsfoot_cnt
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.RabbitsFootCache)

function _Stillbirth:OffalCache(player, cacheFlag)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.offal_i) then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed - 0.1*g_vars.offal_cnt
		end
		if cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck - 0.2*g_vars.offal_cnt
		end
		if cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay + 1*g_vars.offal_cnt
		end
		if cacheFlag == CacheFlag.CACHE_RANGE then
			player.TearHeight = player.TearHeight + 2*g_vars.offal_cnt
		end
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = DamageToSet(player, -0.2*g_vars.offal_cnt, g_vars.cricketspaw_multiplier)
		end
		if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed - 0.1*g_vars.offal_cnt
		end
		if not g_vars.offal_HP_UP_GIVEN then
			player:AddMaxHearts(6)
			player:AddHearts(6)
			g_vars.offal_HP_UP_GIVEN = true
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.OffalCache)

function _Stillbirth:TarotBoosterUpdate()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.tarotbooster_i) and not g_vars.tarotbooster_hasSpawnedCards then
		for i=-2, 0 do
			local x = i%2
			local y = math.floor(i/2)
			local rand = math.random(1, 22)
			if x == 0 and y == 0 then
				x = 1
				y = 1
			end
			x = x*32
			y = y*32
			local pos = player.Position + Vector(x, y)
			Isaac.Spawn(5, 300, rand, pos, Vector(0,0), player)
		end
		local rand = math.random(23, 31)
		local pos = player.Position + Vector(-32, 32)
		Isaac.Spawn(5, 300, rand, pos, Vector(0,0), player)
		g_vars.tarotbooster_hasSpawnedCards = true
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.TarotBoosterUpdate)

--[[
3D Glasses
Dogeek
]]--

local used = 0

function _Stillbirth:Remove3DGlasses()
	local player = Isaac.GetPlayer(0)
	for i=1, used do
		player:RemoveCollectible(245)
	end
	if player:HasCollectible(245) then
		--player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/2020.anm2"))
	end
	used = 0
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, _Stillbirth.Remove3DGlasses)

function _Stillbirth:use_3D_glasses()
    used = used + 1;
    local player = Isaac.GetPlayer(0)
    local room = Game():GetRoom()
    player:AddCollectible(245, 0, false)
    player:TryRemoveCollectibleCostume(245, false)
    return true
end

_Stillbirth:AddCallback( ModCallbacks.MC_USE_ITEM, _Stillbirth.use_3D_glasses, Items.D_glasses_i);
--[[
Spidershot
Azqswx
]]--


function _Stillbirth:SpidershotUpdateTears()
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities();
  if player:HasCollectible(Items.spidershot_i) then
    for i = 1, #entities do
      if entities[i].Type == EntityType.ENTITY_TEAR then
        local entity = entities[i]:ToTear();
        local lifetime = entity.FrameCount;
        local rng = math.random(-10, 30)
        local Luck = player.Luck
        if rng <= Luck and lifetime == 1 and entity.SpawnerType == EntityType.ENTITY_PLAYER then
          entity:AddEntityFlags(1);
        end
        if entity:HasEntityFlags(1) and lifetime == 1 and entity.Variant ~= 27 then
          entity:ChangeVariant(27)
          entity.CollisionDamage = entity.CollisionDamage * 2
        end
      end
    end
  end
end

-- NOTE(krayz): ModCallbacks.MC_ENTITY_TAKE_DMG moved in "mc_entity_take_dmg.lua" file
--~ _Stillbirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.SpidershotEffectOnMob)

local weblist = {}
function _Stillbirth:SpidershotEffectOnGridandCreep()
  local player = Isaac.GetPlayer(0)
  if player:HasCollectible(Items.spidershot_i) then
  	if Game():GetRoom():GetFrameCount() == 1 then weblist = {} end
    local entities = Isaac.GetRoomEntities();
    for i,entity in ipairs(entities) do
      if entity.Type == EntityType.ENTITY_TEAR and entity.Variant == 27 then
        local posTear = entity.Position;
        local oldVeloc = entity.Velocity;
        Isaac.Spawn(1000,44,0,posTear,Vector(0,0),player):ToEffect():SetTimeout(60)
        if entity:CollidesWithGrid() then
          local index = Game():GetRoom():GetGridIndex(posTear-oldVeloc);
          Game():GetRoom():SpawnGridEntity(index,10,0,0,0)
          local web = Game():GetRoom():GetGridEntity(index)
          table.insert(weblist, web)
        end
      end
    end
    for i=1, #weblist do
    	local w = weblist[i]
		if getDistance(player.Position, w.Position)<32 then
			player:AddEntityFlags(1)
		else
			player:ClearEntityFlags(1)
		end
	end
  end
end

_Stillbirth:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, _Stillbirth.SpidershotUpdateTears)
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.SpidershotEffectOnGridandCreep)

--[[ http://pastebin.com/e8tSm91i pools
Item : cricket's tail
Type : augmente les chances de coffres à piques
By : Dogeek
Date : 2017-03-10
]]--

local cricketstail_spawn_delay = 0
local crickets_tail_SPAWN_CHANCE = 33

function _Stillbirth:cricketsTail_hadEnemiesReset()
    g_vars.cricketsTail_hadEnemies = false
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, _Stillbirth.cricketsTail_hadEnemiesReset)

function _Stillbirth:cricketsTailUpdate()
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()
	local room = Game():GetRoom()
	local availablePosition = nil
	if player:HasCollectible(Items.crickets_tail_i) then
		if room:GetFrameCount() == 1 then
			cricketstail_spawn_delay = 0
			for i=1, #entities do
				local e = entities[i]
				if e:IsActiveEnemy(false) then
					g_vars.cricketsTail_hadEnemies = true
				end
			end
		end
		if isRoomOver(room) and room:IsFirstVisit() and room:GetType() == RoomType.ROOM_DEFAULT and g_vars.cricketsTail_hadEnemies then
			local center = GetRoomCenter()
			availablePosition = room:FindFreePickupSpawnPosition(center,32.0,false)
			cricketstail_spawn_delay = cricketstail_spawn_delay + 1
			if cricketstail_spawn_delay == 10 then
				local rand = math.random(100)
				if rand <= crickets_tail_SPAWN_CHANCE and g_vars.cricketsTail_hadEnemies then
					g_vars.cricketsTail_hadEnemies = false
					for i=1, #entities do
						local e = entities[i]
						if e and avalaiblePosition ~= nil then
							if e.Type == 5 and getDistance(e.Postion, availablePosition) <= 32 and not e.Variant==52 then
								e:Remove()
							end
						end
					end
					Isaac.Spawn(5,PickupVariant.PICKUP_SPIKEDCHEST,0,availablePosition,Vector(0,0),player)
				end
			end
		end
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.cricketsTailUpdate)

--[[
<3+<3 = <3<3
Soul Extension
--Dogeek
--Azqswx
]]--

function _Stillbirth:SoulExtensionUpdate()
    local player = Isaac.GetPlayer(0);
    if player:HasCollectible(Items.double_heart_i) then
        local entities = Isaac.GetRoomEntities();
        for i=1,#entities do
            if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_HEART then
                local heart = entities[i];
                if heart.SubType == HeartSubType.HEART_HALF_SOUL then
                    local sprite_HalfSoul = heart:GetSprite();
                    if heart.FrameCount == 1 then
                        sprite_HalfSoul:ReplaceSpritesheet(0, "gfx/items/pickups/sprites/hearts_soulextension.png")
                        sprite_HalfSoul:LoadGraphics()
                    end
                    if sprite_HalfSoul:IsPlaying("Collect") and sprite_HalfSoul:GetFrame() == 2 then
                        player:AddSoulHearts(1);
                    end
                end
                if heart.SubType == HeartSubType.HEART_SOUL then
                    local sprite_Soul = heart:GetSprite();
                    if heart.FrameCount == 1 then
                        sprite_Soul:ReplaceSpritesheet(0, "gfx/items/pickups/sprites/hearts_soulextension.png")
                        sprite_Soul:LoadGraphics()
                    end
                    if sprite_Soul:IsPlaying("Collect") and sprite_Soul:GetFrame() == 2 then
                        player:AddSoulHearts(2);
                    end
                end
                if heart.SubType == HeartSubType.HEART_BLACK then
                    local sprite_Black = heart:GetSprite();
                    if heart.FrameCount == 1 then
                        sprite_Black:ReplaceSpritesheet(0, "gfx/items/pickups/sprites/hearts_soulextension.png")
                        sprite_Black:LoadGraphics()
                    end
                    if sprite_Black:IsPlaying("Collect") and sprite_Black:GetFrame() == 2 then
                        player:AddBlackHearts(2);
                    end
                end
            end
        end
    end
end

_Stillbirth:AddCallback( ModCallbacks.MC_POST_UPDATE, _Stillbirth.SoulExtensionUpdate)
--[[
White candle

Guarantees a blessing without the need of a curse beforehand (doesn't remove curses)
check mechanics/curses.lua for more info

Dogeek
]]--

function _Stillbirth:whiteCandleUpdate()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.white_candle_i) and not g_vars.whiteCandle_EternalHeartAdded then
		g_vars.BLESSING_CHANCE = 1
		player:AddEternalHearts(1)
		g_vars.whiteCandle_EternalHeartAdded = true
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.whiteCandleUpdate)

--[[
Mizaru

Azqswx
]]--

function _Stillbirth:MizaruUpdateCache()
    local frame = Game():GetFrameCount();
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(Items.mizaru_i) and IsShooting(player) then
		if not g_vars.mizaru_n then
			g_vars.mizaru_n = player.MaxFireDelay
		end
		if frame % 75 == 0 then
		    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		    player:EvaluateItems()
		end
	end
end

function _Stillbirth:MizaruRandomFireRate(player, cacheFlag)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.mizaru_i) and cacheFlag == CacheFlag.CACHE_FIREDELAY then
        rng = math.random();
        if g_vars.mizaru_n > 0 then
            fire_delay_base = player.MaxFireDelay - g_vars.mizaru_n;
        elseif g_vars.mizaru_n < 0 then
            fire_delay_base = player.MaxFireDelay + g_vars.mizaru_n;
        elseif g_vars.mizaru_n == 0 then
            fire_delay_base = player.MaxFireDelay;
        end
        if rng < 0.5 and g_vars.mizaru_n <= player.MaxFireDelay*1.25 then
            g_vars.mizaru_n = g_vars.mizaru_n + 3;
            player.MaxFireDelay = g_vars.mizaru_n;
        elseif rng > 0.5 and g_vars.mizaru_n >= player.MaxFireDelay*0.75 then
            g_vars.mizaru_n = g_vars.mizaru_n - 3;
            player.MaxFireDelay = g_vars.mizaru_n;
        end
    end
end

_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.MizaruRandomFireRate)
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.MizaruUpdateCache)

--[[
Passive Item : Kikazaru : Supprime Curse of the Maze & Labyrinth. Larmes de sang bonus sortant des oreilles avec un tear rate de moitié.
-Sliost-
]]--
--counterKikazaru : counter to spawn a tear every 2*MaxFireDelay

function _Stillbirth:HasKikazaru()
  local player = Isaac.GetPlayer(0)
  if player:HasCollectible(Items.kikazaru_i) then
    if g_vars.Kikazaru_oldFrame <= 0 then
      g_vars.Kikazaru_oldFrame = player.FrameCount
    end
    local tearRate = 2*player.MaxFireDelay
    local aimDirection = player:GetAimDirection()
	if IsShooting(player) and (player.FrameCount - g_vars.Kikazaru_oldFrame) > tearRate then
      if aimDirection.X ~= 0 or  aimDirection.Y ~= 0 then
        local angle = aimDirection:GetAngleDegrees()
        local vectorLeft = Vector.FromAngle(angle + 90)*(10*player.ShotSpeed) + player.Velocity
        local vectorRight = Vector.FromAngle(angle - 90)*(10*player.ShotSpeed) + player.Velocity
        local tearLeft = player:FireTear(player.Position, vectorLeft, false, false, false)
        local tearRight = player:FireTear(player.Position, vectorRight, false, false, false)
        tearLeft:ChangeVariant(1)
        tearRight:ChangeVariant(1)
      end
	  g_vars.Kikazaru_oldFrame = player.FrameCount
    end
  end
end

_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.HasKikazaru);

--[[
God Sale
Passive Item : Moitié du shop gratos mais aléatoire à chaque shop. Rajout de shops dans Womb
Dogeek
]]--

function _Stillbirth:GodSaleUpdate()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local entities = Isaac.GetRoomEntities()
	local currentStage = Game():GetLevel():GetStage()
	if player:HasCollectible(Items.godsale_i) then
		if room:GetType() == RoomType.ROOM_SHOP then
			for i=1, #entities do
				local e = entities[i]
				if e.Type == 5 and e.Variant == PickupVariant.PICKUP_SHOPITEM then
					table.insert(g_vars.godsale_freeitems, e)
				end
			end
		    if g_vars.godsale_previousStage ~= currentStage then
		        g_vars.godsale_previousStage = currentStage
				g_vars.godsale_rand = math.random(2^(#g_vars.godsale_freeitems))
				g_vars.godsale_rand = bit.tobits(g_vars.godsale_rand)
				print(g_vars.godsale_rand)
			end
			for i=1, #g_vars.godsale_freeitems do
				if g_vars.godsale_rand[i] == 1 then
					local e = g_vars.godsale_freeitems[i]:ToPickup()
					e.Price = 0
				end
			end
		end
		player:GetEffects():AddTrinketEffect(TrinketType.TRINKET_SILVER_DOLLAR, false);
	end
end
--_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.GodSaleUpdate) --error bit.tobits() bitwise on non integer

--[[
Iwazaru
-- "Baillon qui se met sur la bouche. Quand le joueur se fait toucher, le baillon active un shoop dawoop (1 fois par salle)"
Sliost & Dogeek(pour finir l'item)
]]--

function _Stillbirth:IwazaruFiredReset()
	local room = Game():GetRoom()
	local player = Isaac.GetPlayer(0)
	if g_vars.iwazaru_fired and player:HasCollectible(Items.iwazaru_i) then
		if room:GetFrameCount() == 1 then
			g_vars.iwazaru_fired = false
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.IwazaruFiredReset)

-- NOTE(krayz): ModCallbacks.MC_ENTITY_TAKE_DMG moved in "mc_entity_take_dmg.lua" file
-- _Stillbirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.HasIwazaru,EntityType.ENTITY_PLAYER);


--[[
Passive Item: "Blobby"
Random Isaac's Tears
-Azqswx-
--]]
local blobby_shot = false
function _Stillbirth:blobbyUpdate()
    local player = Isaac.GetPlayer(0);
    if player:HasCollectible(Items.blobby_i) then
    	if blobby_shot then player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/blobby_shoot.anm2")); blobby_shot = false end
        local rngProc_blobby = math.random(-10, 50);
        if rngProc_blobby <= player.Luck and player.FireDelay <= 1 and player:GetFireDirection() ~= -1 then
        	player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/blobby.anm2"))
        	player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/blobby_shoot.anm2"))
        	blobby_shot = true
            player.FireDelay = player.MaxFireDelay;
            player:UseActiveItem(CollectibleType.COLLECTIBLE_ISAACS_TEARS ,false,false,false,false);
        end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE , _Stillbirth.blobbyUpdate);

--[[
Active Item: "Portable restock"
Portable reroll machine
-Azqswx-
--]]

function _Stillbirth:usePortableRestock()
	local player = Isaac.GetPlayer(0);
	local roomType = Game():GetRoom():GetType()
	if player:HasCollectible(Items.portable_restock_i) then
		if player:GetNumCoins() > 0 then
			SFXManager():Play(SoundEffect.SOUND_COIN_SLOT, 1.0, 0, false, 1.0)
			player:AddCoins(-1);
			local luckOfReroll = math.random(-5, 45);
			if luckOfReroll < player.Luck then
				player:UseActiveItem(105,false,false,false,false);
				if roomType == RoomType.ROOM_SHOP then
					player:UseActiveItem(166,false,false,false,false);
				end
			else
				SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN, 1.0, 0, false, 1.0)
			end
			return true
		end
	end
	return false
end
_Stillbirth:AddCallback( ModCallbacks.MC_USE_ITEM, _Stillbirth.usePortableRestock, Items.portable_restock_i );

--[[
Item sans nom : ajoute homing piercing et spectral si full health
--Dogeek
]]--

function _Stillbirth:ItemPeteDeLaLife(player, cacheFlag)
	local max_health = playerHasFullHealth()[3]
	if player:HasCollectible(Items.ItemPeteDeLaLife_i) and max_health and player:GetMaxHearts() >= 2 then
		player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING | TearFlags.TEAR_HOMING
	end
end
--_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.ItemPeteDeLaLife)

--[[
Continuum 2.0
the player can go through walls and appear at the other side
--Dogeek
]]--

function _Stillbirth:Continuum2Update()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	if player:HasCollectible(Items.continuum2_i) then
		local player_index = room:GetGridIndex(player.Position)
		if player_index%room:GetGridWidth() == 0 and player.Velocity.X > 0 then --going to right wall
			player.Position = room:GetGridPosition(player_index+1-room:GetGridWidth())
		elseif player_index%room:GetGridWidth() == 1 and player.Velocity.X < 0 then --going to left wall
			player.Position = room:GetGridPosition(player_index-1+room:GetGridWidth())
		elseif player_index-room:GetGridWidth() <= 0 and player.Velocity.Y < 0 then --going to top wall
			player.Position = room:GetGridPosition(room:GetGridSize()-player_index)
		elseif player_index+room:GetGridWidth() >= room:GetGridSize() and player.Velocity.Y > 0 then --going to bottom wall
			player.Position = room:GetGridPosition(player_index-room:GetGridSize()+room:GetGridWidth())
		end
	end
end

--[[
Dads Whip
A new weapon that deals damage based on distance
--Dogeek
]]--
local function dadsWhipDamage(d, d_min, d_max)
	local dmg = Isaac.GetPlayer(0).Damage
	local x = dmg*math.exp(d_min/d_max) - dmg/2
	return dmg*math.exp(d/d_max) - x
end

local function dadsWhipKnockback(d, d_min, d_max)
	local shotspeed = Isaac.GetPlayer(0).ShotSpeed / 1.5
	local x = shotspeed*math.exp(d_min/d_max) - shotspeed/2
	return shotspeed*math.exp(d/d_max) - x
end

function _Stillbirth:WhipDisableTears(entity, InputHook, buttonAction)
	if entity and entity.Type == EntityType.ENTITY_PLAYER then
		local player = Isaac.GetPlayer(0)
		if player:HasCollectible(Items.DadsWhip_i) then
			if InputHook <=1 and (buttonAction>=4 and buttonAction<=7) then
				return false
			end
		end
	end
	return
end
_Stillbirth:AddCallback(ModCallbacks.MC_INPUT_ACTION, _Stillbirth.WhipDisableTears)

local dadswhip_timer = 0 --nb of frames during which dads whip is deployed
local dadswhip_hitbox = nil
function _Stillbirth:onWhipUpdate()
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()
	local entity_type_filter = {0, 1, 2, 3, 6, 7, 8, 1000, 9001} --pickup : 5 projectile : 9
	local distance_min = 16
	local hitbox_w = 20 --px
	local hitbox_h = 128 --px (3tiles)
	local fireDelayMul = 2
	local direction = -1
	--print(player.Position.X, player.Position.Y)
	if player:HasCollectible(Items.DadsWhip_i) then
		if dadswhip_timer ~= 0 then dadswhip_timer = dadswhip_timer - 1 else dadswhip_hitbox = nil end
		if dadswhip_timer == 0 then --can shoot
			if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) then -- ok
				dadswhip_timer = fireDelayMul*player.MaxFireDelay --change the multiplier to adjust
				local vec1 = Vector(-distance_min, -hitbox_w/2) + player.Position
				local vec2 = Vector(-hitbox_h-distance_min, hitbox_w/2) + player.Position
				dadswhip_hitbox = {vec1, vec2}
				direction = Direction.LEFT
			elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex) then--ok
				dadswhip_timer = fireDelayMul*player.MaxFireDelay
				local vec1 = Vector(distance_min, -hitbox_w/2) + player.Position
				local vec2 = Vector(hitbox_h+distance_min, hitbox_w/2) + player.Position
				dadswhip_hitbox = {vec1, vec2}
				direction = Direction.RIGHT
			elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex) then -- ok
				dadswhip_timer = fireDelayMul*player.MaxFireDelay
				local vec1 = Vector(hitbox_w/2, distance_min) + player.Position
				local vec2 = Vector(-hitbox_w/2, -hitbox_h-distance_min) + player.Position
				dadswhip_hitbox = {vec1, vec2}
				direction = Direction.UP
			elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) then--ok
				dadswhip_timer = fireDelayMul*player.MaxFireDelay
				local vec1 = Vector(-hitbox_w/2, distance_min) + player.Position
				local vec2 = Vector(hitbox_w/2, hitbox_h+distance_min) + player.Position
				dadswhip_hitbox = {vec1, vec2}
				direction = Direction.DOWN
			end
		end
		if dadswhip_hitbox and direction ~= -1 then
			local whip_vec = (dadswhip_hitbox[2]-dadswhip_hitbox[1]):Normalized()
			for i=1, #entities do
				local e = entities[i]
				if not has_value(entity_type_filter, e.Type) then
					if isPositionInHitbox(e.Position, dadswhip_hitbox, direction) then
						local d = (e.Position-player.Position):Dot(whip_vec)
						local velmul = dadsWhipKnockback(d, distance_min, hitbox_h)
						e:TakeDamage(dadsWhipDamage(d, distance_min, hitbox_h), 1<<3, EntityRef(player), 0)
						e:AddConfusion(EntityRef(player), fireDelayMul*player.MaxFireDelay, false)
						e:AddVelocity(whip_vec*velmul)
					end
				end
			end
			dadswhip_hitbox = nil
		end
		--[[if dadswhip_timer >0 then
			if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) then
				player:QueueExtraAnimation("HeadLeft")
			elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex) then
				player:QueueExtraAnimation("HeadRight")
			elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex) then
				player:QueueExtraAnimation("HeadUp")
			elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) then
				player:QueueExtraAnimation("HeadDown")
			end
		end]]--
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.onWhipUpdate)
--[[--END--]]

