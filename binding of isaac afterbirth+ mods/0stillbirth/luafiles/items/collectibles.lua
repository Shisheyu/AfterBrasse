--[[
Debug item to spawn every custom item we have
--Dogeek
]]--
function _Stillbirth:onUseDebugItem()
	local center = Game():GetRoom():GetCenterPos()
	for i=1, #Items do
		Isaac.Spawn(5, 100, Items[i], Isaac.GetFreeNearPosition(center, 32.0), Vector(0,0), player)
	end
	return true
end
_Stillbirth:AddCallback(ModCallbacks.MC_USE_ITEM, _Stillbirth.onUseDebugItem, Items.debug_i)

--[[
Passive Item: "Blobby"
Random Isaac's Tears
-Azqswx-
--]]

function _Stillbirth:blobbyUpdate()
    local player = Isaac.GetPlayer(0);
    if player:HasCollectible(Items.blobby_i) then
        local rngProc_blobby = math.random(-10, 30);
        if rngProc_blobby <= player.Luck and player.FireDelay <= 1 and player:GetFireDirection() ~= -1 then
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
      player:AddCoins(-1);
      local luckOfReroll = math.random(0,50);
      if luckOfReroll < player.Luck then
        player:UseActiveItem(105,false,false,false,false);
        if roomType == RoomType.ROOM_SHOP then
        player:UseActiveItem(166,false,false,false,false);
        end
      end
    end
  end
  return true;
end

_Stillbirth:AddCallback( ModCallbacks.MC_USE_ITEM, _Stillbirth.usePortableRestock, Items.portable_restock_i );

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
function _Stillbirth:braveShoeDamage(entity, dmg_amount, dmg_flag, dmg_src, dmg_countdown)
    local player = Isaac.GetPlayer(0)
	local roomType = Game():GetRoom():GetType()
    if player:HasCollectible(Items.brave_shoe_i) then
        if (dmg_flag == DamageFlag.DAMAGE_SPIKES and roomType ~= RoomType.ROOM_SACRIFICE) then
            return false
        end
    end
    return
end

function _Stillbirth:braveShoeCache(player, cacheFlag)
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(Items.brave_shoe_i) then
        if (cacheFlag == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed + 0.2;
        end
    end
end
_Stillbirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.braveShoeDamage, EntityType.ENTITY_PLAYER)
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
--]]
function _Stillbirth:medusaHead_use()

    local enemies = Isaac.GetRoomEntities();
    local player = Isaac.GetPlayer(0);
    local range = math.abs(GetRange(player) * 12.5);
    local vec = player.Position;
    local dir = player:GetHeadDirection();
	SFXManager():Play(18, 1.0, 1, false, 1.0)
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
Tire de temps à autres une larme feuille qui stopwatch les ennemis
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
local tearLeaf_t = nil
local tearLeaf_boss = nil

function _Stillbirth:TearLeaf_MobSlowing( entity, damage, flag, source, countdown ) -- CustomTearEffect
    if entity and entity:IsVulnerableEnemy() then
        if source.Type == 2 and source.Variant == CustomEntities.TearLeaf_Variant then
		    if entity:IsBoss() then --boss differenciation
		    	tearLeaf_t = Isaac.GetFrameCount()
		    	tearLeaf_boss = entity
		    	entity:AddEntityFlags( 1 << 7 ) -- Slow flag
		    	entity:SetColor( Color( 0.8, 0.8, 0.8, 0.85, 120, 120, 120 ), 180, 50, false, false ) -- StopWatch like color
		    else
		    	entity:AddEntityFlags( 1 << 7 ) -- Slow flag
		    	entity:SetColor( Color( 0.8, 0.8, 0.8, 0.85, 120, 120, 120 ), 9999, 50, false, false ) -- StopWatch like color
		    end
        end
    end
    return
end
_Stillbirth:AddCallback( ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.TearLeaf_MobSlowing );

function _Stillbirth:TearLeaf_BossTimer()
	if tearLeaf_t then
		if Isaac.GetFrameCount() - tearLeaf_t >= 6*60 then
			tearLeaf_boss:ClearEntityFlags(1<<7)
			tearLeaf_t = nil
			tearLeaf_boss = nil
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.TearLeaf_BossTimer)

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
function _Stillbirth:OnBlankTissueUse()
    local player = Isaac.GetPlayer(0)
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
--~ this item don't need save
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

function _Stillbirth:ExBanana_Mine()
    local player = Isaac.GetPlayer(0)

    if ( player:HasCollectible(Items.ExBanana_i) ) then
        local entities = Isaac.GetRoomEntities()
        local room = Game():GetRoom()
        if room:GetFrameCount() == 1 then ExBanana_resetVars() end -- reset vars every room
        if BanaV.Ready and IsShooting(player) then
            player:TryRemoveNullCostume(BanaV.costume)
            Velocity = Vector( ((player:GetLastDirection().X*8) + (player:GetVelocityBeforeUpdate().X*1.1)), (( player:GetLastDirection().Y*8 ) + (player:GetVelocityBeforeUpdate().Y*1.1)) )
            BanaV.ExBanana = Game():Spawn(CustomEntities.BananaEntity, 0, player.Position:__sub( Vector(0, -5) ), Vector(0,0), player, 0, 0) -- Explosive Banana
            BanaV.ExBanana.Friction = 1
            BanaV.ExBanana:ClearEntityFlags( 1<<2 )
            BanaV.ExBanana:AddEntityFlags( 1<<5 )
            BanaV.ExBanana:AddVelocity( Velocity:__mul(1.15) )
            BanaV.ExBanana:ClearEntityFlags( 1<<5 )
            BanaV.ExBanana:AddEntityFlags( 1<<0|1<<4|1<<15|1<<26|1<<29|1<<30 )
            BanaV.ExBananaSprite = BanaV.ExBanana:GetSprite();
            BanaV.ExBanana.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
            BanaV.ExBanana.GridCollisionClass = 5 -- 5 = allgrid ent 6 = nopits ; 3 = wall only
            BanaV.ExBananaSprite:Play("Idle", true);
            BanaV.ExBanana.RenderZOffset  = 5
            BanaV.ExBananaSpawned = true
            BanaV.ExBananaActive = false
            BanaV.Ready = false
        elseif BanaV.ExBananaSpawned and not BanaV.ExBananaActive then
            BanaV.ExBanana_frame = BanaV.ExBanana_frame + 1
            if BanaV.ExBanana:CollidesWithGrid() then
                BanaV.ExBanana:MultiplyFriction( 0.3 )
            end
            if BanaV.ExBanana_frame < 18 then
                local amp = inQuad( BanaV.ExBanana_frame * 0.60, 1, 9-1, 9 )
                db_a = amp
                BanaV.ExBanana.PositionOffset = Vector( 0, amp ) -- Zou
            elseif BanaV.ExBanana_frame < 40 then
                BanaV.ExBanana.PositionOffset = Vector( 0,14 ) -- EndCourseOnTheFloor
                BanaV.ExBanana:MultiplyFriction( 0.05 ) -- StopMoving
                if not BanaV.CreepSpawn then
                    BanaV.ExBananaCreep2 = Isaac.Spawn( 1000, 24, 0, BanaV.ExBanana.Position, Vector(0, 0), player ) -- ExBanana Creep2 Yl
                    BanaV.ExBananaCreep2:AddEntityFlags( 1<<0|1<<4|1<<15|1<<26|1<<29|1<<30 )
                    BanaV.ExBananaCreep2:SetColor( Color( 1.0, 1.0, 0.0, 0.0, 255, 255, 0 ) , 9999, 9999, false, false )
                    BanaV.ExBananaCreep2.SpriteScale = BanaV.ExBananaCreep2.SpriteScale * 6.0
                    BanaV.ExBananaCreep2:ToEffect():SetTimeout(9999)
                    SFXManager():Play(445, 0.9, 0, false, 0.45)
                    BanaV.CreepSpawn = true
                end
            elseif BanaV.ExBanana_frame <= 70 then
                local a = (BanaV.ExBanana_frame - 40)
                BanaV.ExBananaCreep2:SetColor( Color( 1.0, 1.0, 0.0, a/100 , 255, 255, 0 ) , 9999, 9999, false, false ) -- creep
                BanaV.ExBanana:SetColor( Color( (a/200)+0.15, 0.15, 0.0, 1.0, 0, 0, 0 ) , 9999, 9999, false, false ) -- banana
                if a == 20 then
                    BanaV.ExBananaCreep = Isaac.Spawn( 1000, 44, 0, BanaV.ExBanana.Position, Vector(0, 0), player ) -- ExBanana Creep Sl -- Add Delay befor slow
                    BanaV.ExBananaCreep:AddEntityFlags( 1<<0|1<<4|1<<15|1<<26|1<<29|1<<30 )
                    BanaV.ExBananaCreep:SetColor( Color( 0.0, 0.0, 0.0, 0.0, 0, 0, 0 ) , 9999, 9999, false, false )
                    BanaV.ExBananaCreep.SpriteScale = BanaV.ExBananaCreep.SpriteScale * 5.0
                    BanaV.ExBananaCreep:ToEffect():SetTimeout(9999)
                end
            else
                if not BanaV.ExBananaSprite:IsPlaying( "Float" ) then
                    BanaV.ExBananaSprite:Play( "Float", true )
                    SFXManager():Play(229, 0.4, 0, false, 2.5)
                end
                BanaV.ExBananaCreep.Position = BanaV.ExBanana.Position
                BanaV.ExBananaCreep2.Position = BanaV.ExBanana.Position
                BanaV.ExBananaActive = true -- Start damage/effect
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

local function addMissingItem(pool)
	local player = Isaac.GetPlayer(0)
	local choice = {}
	for i=1, #pool do
		if not player:HasCollectible(pool[i]) and pool[i] ~= 81 then
			table.insert(choice, pool[i])
		end
		for i=1, #activeList do
			if not has_value(activeList, pool[i]) then
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
	if player:HasCollectible(Items.ottid_i) and (g_vars.ottid_init_check or  player:GetCollectibleCount()>g_vars.ottid_collectible_count)then
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

function _Stillbirth:SpidershotEffectOnMob(DmgEntity, DamageAmount, DamageFlags, DamageSource, DamageCountdown)
  local player = Isaac.GetPlayer(0)
  if player:HasCollectible(Items.spidershot_i) then
    if DamageSource.Type == EntityType.ENTITY_TEAR and DamageSource.Variant == 27 then
      local posE = DmgEntity.Position;
      index = Game():GetRoom():GetGridIndex(posE);
      Game():GetRoom():SpawnGridEntity(index,10,0,0,0)
      DmgEntity:AddEntityFlags(1<<7)
    end
  end
end

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
_Stillbirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.SpidershotEffectOnMob)
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.SpidershotEffectOnGridandCreep)

--[[ http://pastebin.com/e8tSm91i pools
Item : cricket's tail
Type : augmente les chances de coffres à piques
By : Dogeek
Date : 2017-03-10
]]--

local cricketstail_spawn_delay = 0
local crickets_tail_SPAWN_CHANCE = 25

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
Azqswx
]]--

function _Stillbirth:HeartPlusHeartUpdate()

	local player = Isaac.GetPlayer(0);
	local bHeart = player:GetSoulHearts();
	local Heart = player:GetMaxHearts();

	if player:HasCollectible(Items.double_heart_i) then
		local coeur = Isaac.GetRoomEntities();
		local vec = player.Position;
		local fullhealth = playerHasFullHealth()
		for i = 1, #coeur do 					-- VERIFIER SI ORDRE DES COEURS CHANGE : Ordre change :'(
			if (coeur[i].Type == 5) and (coeur[i].Variant == 10) then	--Test si de type: pickup + coeur
				local sprite = coeur[i]:GetSprite();					-- Récupération sprite coeur
				local bval =  math.abs( coeur[i].Position.X - player.Position.X ) + math.abs( coeur[i].Position.Y - player.Position.Y )		--Calcul distance relative à Isaac
				local cpos = coeur[i].Position
				local tl = cpos-Vector(16,16)
				local br = cpos+Vector(16,16)
				if not fullhealth[1] then
					if coeur[i].SubType == HeartSubType.HEART_HALF_SOUL then
						if coeur[i].EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE then
							coeur[i].EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
						end
						coeur[i]:AddEntityFlags(1<<25);
						sprite:Load("gfx/items/pickups/soulheart.anm2" , true)	--Remplace le sprite par le sprite x1
						sprite:Render(cpos, tl, br);
						sprite:Play("Idle", true)
						if bval < 40 then									--Test si possibilité de prendre coeur bleu + Isaac sur coeur + coeur est bleu
							SFXManager():Play(185,1.0,1,false,1.0)			--Joue son PickUp heart
							player:AddSoulHearts(2)							--Rajoute 2coeurs bleus
							coeur[i]:Remove()
						end
					end

					if coeur[i].SubType == HeartSubType.HEART_SOUL and coeur[i]:GetEntityFlags() ~= 1<<25 then 	--Si coeur bleu ET PAS ANCIEN DEMI COEUR
						if coeur[i].EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE then
							coeur[i].EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
						end
						sprite:Load("gfx/items/pickups/doublesoulheart.anm2" , true)	--Remplace le sprite par le sprite x2
						sprite:Render(cpos, tl, br);
						sprite:Play("Idle", true)
						if bval < 40 then									--Test si possibilité de prendre coeur bleu + Isaac sur coeur + coeur est bleu
							SFXManager():Play(185,1.0,1,false,1.0)			--Joue son PickUp heart
							player:AddSoulHearts(4)							--Rajoute 2coeurs bleus
							coeur[i]:Remove()
						end
					end
				else
					BounceHearts(coeur[i])
				end
				if not fullhealth[2] then
					if coeur[i].SubType == HeartSubType.HEART_BLACK and coeur[i]:GetEntityFlags() ~= 1<<25 then
						if coeur[i].EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE then
							coeur[i].EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
						end
						sprite:Load("gfx/items/pickups/doubleblackheart.anm2" , true);
						sprite:Render(cpos, tl, br);
						sprite:Play("Idle", true)
						if bval < 40 and player:CanPickBlackHearts() then
							SFXManager():Play(185,1.0,1,false,1.0)
							player:AddBlackHearts(4)
							coeur[i]:Remove()
						end
					end
				else
					BounceHearts(coeur[i])
				end
			end
		end
	end
end

_Stillbirth:AddCallback( ModCallbacks.MC_POST_UPDATE, _Stillbirth.HeartPlusHeartUpdate);

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
		if frame % 30 == 0 then
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
            g_vars.mizaru_n = g_vars.mizaru_n + 1;
            player.MaxFireDelay = g_vars.mizaru_n;
        elseif rng > 0.5 and g_vars.mizaru_n >= player.MaxFireDelay*0.75 then
            g_vars.mizaru_n = g_vars.mizaru_n - 1;
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

function _Stillbirth:HasIwazaru(entity,dmg_amount, dmg_flag, dmg_src, dmg_countdown)
  local player = Isaac.GetPlayer(0)
  if player:HasCollectible(Items.iwazaru_i) and not g_vars.iwazaru_fired then
  	g_vars.iwazaru_fired = true
    local angle = player:GetAimDirection():GetAngleDegrees()
    local shoop = EntityLaser.ShootAngle(3,player.Position,angle,30,Vector(0,-20),player)
    shoop.CollisionDamage = 2 -- TODO : Adjust value?
  end
  return true
end
_Stillbirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, _Stillbirth.HasIwazaru,EntityType.ENTITY_PLAYER);
--[[--END--]]
