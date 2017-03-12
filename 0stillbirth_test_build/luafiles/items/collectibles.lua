
--[[
Active Item: "Cricket's Paw"
-Sliost-
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
    if g_vars.cricketsPaw_had then
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            for i=1, g_vars.cricketsPaw_Uses do
                player.Damage = player.Damage * 1.1 -- TO BALANCE
            end
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

    for i = 1, #entities do
        if entities[i]:IsVulnerableEnemy( ) then
            -- Ajout confusion et dmg aux ennemis --
            entities[i]:AddConfusion( EntityRef(p), 100, false )
            entities[i]:TakeDamage(10.0,0,EntityRef(p),1)
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
function _Stillbirth:take_damage(entity, dmg_amount, dmg_flag, dmg_src, dmg_countdown)
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(Items.brave_shoe_i) then
        if (dmg_flag == DamageFlag.DAMAGE_SPIKES) then
            return false
        end
    end
    return
end

function _Stillbirth:cacheUpdate(player, cacheFlag)
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(Items.brave_shoe_i) then
        if (cacheFlag == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed + 0.2;
        end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.take_damage, EntityType.ENTITY_PLAYER)
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.cacheUpdate)

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
            player.Damage = player.Damage + 1;
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
    player:AddSoulHearts(2);
    player:AddGoldenHearts(1);
    return true
end
_Stillbirth:AddCallback(ModCallbacks.MC_USE_ITEM, _Stillbirth.GoldenIdol_onUse, Items.golden_idol_i);

--[[
Active item : Medusa's Head
-Azqswx-
--]]
function _Stillbirth:medusaHead_use()

    local enemies = Isaac.GetRoomEntities();
    local player = Isaac.GetPlayer(0);
    local range = math.abs(GetRange(player) * 12.5);
    local vec = player.Position;
    local dir = player:GetHeadDirection();

    for i = 1, #enemies do
        if enemies[i]:IsVulnerableEnemy(enemies[i]) then        --Test si entité = ennemi
            local vecE = enemies[i].Position;
            local posRelatX = vecE.X - vec.X;               --Calcul position X relative du mob par rapport à Isaac
            local posRelatY = vecE.Y - vec.Y;               --Calcul position Y relative du mob par rapport à Isaac
            local distance = math.sqrt((vec.X-vecE.X)^2+(vec.Y-vecE.Y)^2);      --Calcul de la distance entre le mob et Isaac

            if distance < range  then
                local angle = math.deg(math.atan(posRelatY, posRelatX))     --Calcul de l'angle entre le mob et l'axe X d'Isaac
                if not enemies[i]:IsBoss() then                             --Test si ennemi est un boss ou pas
                    if ((dir == 1) and (-112.5 < angle) and (angle < -67.5))then      --Test si Isaac regarde haut/bas/gauche/droite + test si mob dans un cône de 45°
                        enemies[i]:AddEntityFlags(1<<5)                           -- "1<<5" = Flag for freezing entity
                        enemies[i]:SetColor(Color(0.25,0.25,0.25,1,39,39,39),1000000,99,false,true)        --Change la couleur
                    elseif ((dir == 2) and (-22.5 < angle) and (angle < 22.5)) then
                        enemies[i]:AddEntityFlags(1<<5)
                        enemies[i]:SetColor(Color(0.25,0.25,0.25,1,39,39,39),1000000,99,false,true)
                    elseif ((dir == 3) and (angle < 112.5) and (67.5 < angle)) then
                        enemies[i]:AddEntityFlags(1<<5)
                        enemies[i]:SetColor(Color(0.25,0.25,0.25,1,39,39,39),1000000,99,false,true)
                    elseif ((dir == 0) and ((angle < -157.5) or (angle > 157.5))) then
                        enemies[i]:AddEntityFlags(1<<5)
                        enemies[i]:SetColor(Color(0.25,0.25,0.25,1,39,39,39),1000000,99,false,true)
                    end
                else
                    if ((dir == 1) and (-112.5 < angle) and (angle < -67.5))then
                        enemies[i]:AddFreeze(EntityRef(player), 150)                   --Affecte Freeze(5sec)
                    elseif ((dir == 2) and (-22.5 < angle) and (angle < 22.5)) then
                        enemies[i]:AddFreeze(EntityRef(player), 150)
                    elseif ((dir == 3) and (angle < 112.5) and (67.5 < angle)) then
                        enemies[i]:AddFreeze(EntityRef(player), 150)
                    elseif ((dir == 0) and ((angle < -157.5) or (angle > 157.5))) then
                        enemies[i]:AddFreeze(EntityRef(player), 150)
                    end
                end
            end
        end
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
            g_vars.blindPact_previousStage = currentStage
            local rand = math.random(#devilPoolPassive)
            g_vars.blindPact_pickedItem = devilPoolPassive[rand]
            player:AddCollectible(g_vars.blindPact_pickedItem, 0, true)
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
            player.Damage = player.Damage + 2
        end
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay - 3
        end
        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + 0.6
        end
        if cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + 3
        end
        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + 0.3
        end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.SolomonCacheUp)

function _Stillbirth:SolomonUpdate() -- ToDo: Séparer la désactivation de la hitBox coeur noir / bleu
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(Items.solomon_i) then
        local entities = Isaac.GetRoomEntities()
        local redHearts = player:GetMaxHearts()
        local soulHearts = player:GetSoulHearts()
        if (redHearts+soulHearts > 12) then
            if (soulHearts ~= 0) then
                player:AddSoulHearts(-1)
                for i = 1, #entities do
                    local e = entities[i]
                    if e.Type == 5 and e.Variant == 10 and (e.SubType == HeartSubType.HEART_SOUL or e.SubType == HeartSubType.HEART_HALF_SOUL or e.SubType == HeartSubType.HEART_BLACK) then
                        e.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    end
                end
            else
               player:AddMaxHearts(-2, false)
            end
        elseif (redHearts+soulHearts)<12 or not IsFullBlackHearts(player) then
            for i = 1, #entities do
                local e = entities[i]
                if e.Type == 5 and e.Variant == 10 and (e.SubType == HeartSubType.HEART_SOUL or e.SubType == HeartSubType.HEART_HALF_SOUL or e.SubType == HeartSubType.HEART_BLACK) then
                    e.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
                end
            end
        else
            for i = 1, #entities do
                local e = entities[i]
                    if e.Type == 5 and e.Variant == 10 and (e.SubType == HeartSubType.HEART_SOUL or e.SubType == HeartSubType.HEART_HALF_SOUL or e.SubType == HeartSubType.HEART_BLACK) then
                    e.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                end
            end
        end
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
        player:AddCacheFlags(CacheFlag.CACHE_LUCK)
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.SolomonUpdate)

--[[
Cataracte : Epiphora pour le dommage et le tear delay
--Dogeek
-k
--]]
local cataracte_numberOfTearsShot = 0
local cataracte_previousDirection = -1
local cataracte_baseDamage = 0
local cataracte_baseShotSpeed = 0
local cataracte_restored_values = -999
local cataracte_oldFrame = -1

function _Stillbirth:cataract_EvCache(player, cacheFlag)
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(Items.cataracte_i) then
        if IsShooting(player) then
            cataracte_restored_values = -99
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + (player.Damage*0.05+cataracte_numberOfTearsShot*0.5) * cataracte_numberOfTearsShot
            end
            if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
                player.ShotSpeed = player.ShotSpeed - (player.ShotSpeed*0.12) * cataracte_numberOfTearsShot
            end
            if player:GetFireDirection() ~= cataracte_previousDirection then
                cataracte_numberOfTearsShot = 0
                player.Damage = cataracte_baseDamage
                player.ShotSpeed = cataracte_baseShotSpeed
            end
        end
        if not cataracte_restored_values then
            cataracte_numberOfTearsShot = 0
            player.Damage = cataracte_baseDamage
            player.ShotSpeed = cataracte_baseShotSpeed
            cataracte_restored_values = true
        end
    end
end

function _Stillbirth:cataract_PostUpdate()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(Items.cataracte_i) then
        dbz = cataracte_numberOfTearsShot
        if cataracte_restored_values == -999 then
            cataracte_baseDamage = player.Damage
            cataracte_baseShotSpeed = player.ShotSpeed
            cataracte_restored_values = -99
        end
        if IsShooting(player) then
            if (player.FrameCount - cataracte_oldFrame) < 0 then
                cataracte_oldFrame = player.FrameCount
            end
            cataracte_previousDirection = player:GetFireDirection()
            if (player.FrameCount - cataracte_oldFrame) >= Secondes30fps(3.2-(cataracte_numberOfTearsShot*0.3)) then
                if cataracte_numberOfTearsShot < 3 then
                    cataracte_numberOfTearsShot = cataracte_numberOfTearsShot + 1
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
                    player:EvaluateItems()
                end
                cataracte_oldFrame = player.FrameCount
            end
        else
            if cataracte_restored_values == -99 then
                cataracte_restored_values = false
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
                player:EvaluateItems()
            end
            cataracte_oldFrame = player.FrameCount
            cataracte_baseDamage = player.Damage
            cataracte_baseShotSpeed = player.ShotSpeed
        end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.cataract_EvCache)
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.cataract_PostUpdate)

--[[
-Krayz
Item Passif : Bubble's Head
Tire de temps à autres une larme feuille qui stopwatch les ennemis
--]]
local function GetClosestTear(entities, player, TType, TVariant)
    local e, tmp = nil, 0xFFFFFF
    for i=1, #entities do
        local bval =  entities[i].Position:Distance(player.Position)
        if entities[i].Parent and entities[i].Type == TType and entities[i].Variant ~= TVariant and entities[i].Parent.Type == 1 and bval < tmp then
            tmp = bval
            e = entities[i]
        end
    end
    return e
end

function _Stillbirth:BubblesHead_Update()
    local player = Isaac.GetPlayer(0)
    local entities = Isaac.GetRoomEntities()

    if player:HasCollectible(Items.BubblesHead_i) then
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
            if ( v.X == 1 or v.X == 0 ) and ( v.Y == 1 or v.Y == 0 ) and rand > 0.923 and g_vars.BubblesHead_ShootedTears > 4 then
                local tear = GetClosestTear( entities, player, 2, CustomEntities.TearLeaf_Variant )
                local vel = Vector(7.5*player.ShotSpeed,7.5*player.ShotSpeed)
                if tear then
                    vel = tear.Velocity
                    tear:Remove()
                end
                g_vars.BubblesHead_ShootedTears = 0
                ShootCustomTear( CustomEntities.TearLeaf_Variant, player, player, 1.0, vel:__mul(1.2), true )
            end
        end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.BubblesHead_Update)

--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function _Stillbirth:TearLeaf_MobSlowing( entity, damage, flag, source, countdown ) -- CustomTearEffect
    if entity and entity:IsVulnerableEnemy() then
        if source.Type == 2 and source.Variant == CustomEntities.TearLeaf_Variant then
        entity:AddEntityFlags( 1 << 7 ) -- Slow flag
        entity:SetColor( Color( 0.8, 0.8, 0.8, 0.85, 120, 120, 120 ), 9999, 50, false, false ) -- StopWatch like color
        end
    end
    return
end
_Stillbirth:AddCallback( ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.TearLeaf_MobSlowing );

--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function _Stillbirth:FirstBloodEffect() -- Only one tear Version (event with quad shot only one OP tear)
    local player = Isaac.GetPlayer(0);
    local roomframe = Game():GetRoom():GetFrameCount();
    local entities = Isaac.GetRoomEntities();

    if roomframe == 1 then
        g_vars.FirstBlood_Done = false
    end
    if player:HasCollectible(Items.first_blood_i) then
        if not g_vars.FirstBlood_Done then
            for i = 1, #entities do
                if (entities[i].Type == EntityType.ENTITY_TEAR) and (entities[i]:GetLastParent().Type == player.Type) and not g_vars.FirstBlood_Done then -- g_vars.FirstBlood_Done here so it trigger for 1 tear only . MAY CHANGE
                    local e = entities[i]:ToTear()
                    g_vars.FirstBlood_Done = true
                    e:SetDeadEyeIntensity(0.2)
                    e.Scale = 1 + (e.CollisionDamage * 0.5)
                    e.CollisionDamage  = e.CollisionDamage  + 50
                    if entities[i].FrameCount <= 1 then
                        e:ChangeVariant(1);
                    end
                end
            end
        end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.FirstBloodEffect)

--[[
Blank Tissue : supprime toute les larmes de la salle
--Dogeek
]]--

function _Stillbirth:OnBlankTissueUse()
    local player = Isaac.GetPlayer(0)
    local entities = Isaac.GetRoomEntities()
    for i=1, #entities do
    	if entities[i].Type == EntityType.ENTITY_TEAR then
    		entities[i]:Delete()
    	end
    end
end

_Stillbirth:AddCallback(ModCallbacks.MC_USE_ITEM, _Stillbirth.OnBlankTissueUse, Items.blankTissues_i)

--[[
Item Passive : Choranaptyxic : Stats basées sur grande ou petite salle. Salle neutre ne modifie pas
--Dogeek

Tear rate + speed petite
Range + damage dans les grandes
]]--


local chora_bdmg = 0
local chora_brange = 0
local chora_bspeed = 0
local chora_btears = 1
local chora_lastShape = 0

function _Stillbirth:ChoranaptyxicCache(player, cacheFlag)
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(Items.choranaptyxic_i) then
        if cacheFlag==CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + bdmg
        end
           if cacheFlag==CacheFlag.CACHE_RANGE then
            player.TearHeight = player.TearHeight + brange
        end
        if cacheFlag==CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + bspeed
        end
        if cacheFlag==CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay*btears
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
				chora_bspeed = 1
				chora_btears = 0.5
			elseif roomShape == RoomShape.ROOMSHAPE_1x2 or roomShape == RoomShape.ROOMSHAPE_2x1 or roomShape == RoomShape.ROOMSHAPE_2x2 or roomShape == RoomShape.ROOMSHAPE_LTL or roomShape == RoomShape.ROOMSHAPE_LTR or roomShape == RoomShape.ROOMSHAPE_LBL or roomShape == RoomShape.ROOMSHAPE_LBR then
				chora_bdmg = 2
				chora_brange = -10
				chora_bspeed = 0
				chora_btears = 1
			else
				chora_bdmg = 0
				chora_brange = 0
				chora_bspeed = 0
				chora_btears = 1
			end
			
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:AddCacheFlags(CacheFlag.CACHE_RANGE)
			player:EvaluateItems()
		end
    end
	chora_lastShape = roomShape
end

_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.ChoranaptyxicUpdate)
_Stillbirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Stillbirth.ChoranaptyxicCache) 
