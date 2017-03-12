--[[
Stillbirth
--]]
local math = math
local table = table
table._getn = function(t) local n = 0 if type(t) ~= type({}) then return -1 end for k,v in pairs(t) do n = n + 1 end return n end

local _Mod = RegisterMod("Stillbirth", 1)

--	##################################### SaveSysFunctions #################################
--[[Krayz --]]
local function IsNewGame() -- New run detection
	local game = Game()
	if game:GetFrameCount() == 0 and game:GetVictoryLap() == 0 then return true else return false end
end
local function ResetSave() -- Reset saved data
	if Isaac.HasModData(_Mod) then Isaac.RemoveModData(_Mod) return true end return false
end
local function _save_(dataTable) -- Save Sys
	if dataTable then
		local dataString = ""
		for k,v in pairs(dataTable) do dataString = tostring(k) .. " " .. tostring(v) .. ";" .. dataString end
		Isaac.SaveModData( _Mod, dataString )
		return true
	end
	return false
end
local function _load_() -- load Sys
	local dataTable = {}
	if Isaac.HasModData(_Mod) then
		local dataString = Isaac.LoadModData(_Mod)
		for k,v in string.gmatch( dataString, "(%w+[_%w+]+)%s([.,%?-_!^%w+%s+]+)" ) do
			if v == "false" then dataTable[k] = false
			elseif v == "true" then dataTable[k] = true
			elseif tonumber(v) ~= nil then dataTable[k] = tonumber(v)
			else dataTable[k] = v end
		end
		return dataTable
	end
	return nil
end

--	####################################################################################

local Items =	{
						moneyLuck_i = Isaac.GetItemIdByName( "Money = Luck" ),
						Beer_i = Isaac.GetItemIdByName( "Dad's Beer" ),
						brave_shoe_i = Isaac.GetItemIdByName( "Brave Shoe" ),
						tech0_i = Isaac.GetItemIdByName("Technology 0"),
						hot_pizza_slice_i = Isaac.GetItemIdByName("Hot Pizza Slice"),
						golden_idol_i = Isaac.GetItemIdByName("Golden Idol"),
						medusa_head_i = Isaac.GetItemIdByName("Medusa's Head"),
						blind_Pact_i = Isaac.GetItemIdByName("Blind Pact"),
						cricketsPaw_i = Isaac.GetItemIdByName("Cricket's Paw"),
						solomon_i = Isaac.GetItemIdByName("salomon"),
						cataracte_i = Isaac.GetItemIdByName("cataracte"),
						BubblesHead_i = Isaac.GetItemIdByName( "Bubble's Head" ),
						SunWukong_i = Isaac.GetItemIdByName("SunWukong"),
						FAM_BombBum_i = Isaac.GetItemIdByName("fam_BombBum_I")
						--mizaru_i = Isaac.GetItemIdByName("Mizaru")
					}

local Familiars =	{
							SunWukong_Familiar_Variant = Isaac.GetEntityVariantByName("SunWukong"),
							FAM_BombBumFamiliar = Isaac.GetEntityTypeByName("fam_BombBum"),
							FAM_BombBumFamiliarVariant = Isaac.GetEntityVariantByName("fam_BombBum")
						}

local CustomEntities =	{
									TearLeaf_Variant = Isaac.GetEntityVariantByName( "Tear leaf" )
								}

local s = _load_() -- Save Load
local function data_Init()
	local g_vars =	{ -- Here goes the global variables
								GlobalSeed = 0,
								MoneyIsPower_OldCoins = 0,
								tech0_oldFrame = nil,
								tech0_n = 1.0,
								tech0_OldRoom = nil,
								blindPact_pickedItem = 0,
								blindPact_previousItem = 0,
								blindPact_previousStage = 0,
								cricketsPaw_Uses = 0,
								cricketsPaw_had= false,
								legacy_spawned = false,
								legacy_lastRoom = nil,
								BubblesHead_ShootedTears = 0, -- whatever
								BubblesHead_oldFrame = nil, -- ?
								FAM_SunWukongExists = false, -- need save
								FAM_SunWukongCounter = 0, -- whatever
								FAM_SunWukong_oldFrame = nil, -- ?
								FAM_BombBumExists = false, -- need save
								FAM_BombCounter = 0,
								FAM_nBombBeforDrop = 10 -- Num of bomb the bum will eat before vomiting a trinket
							}
	return g_vars
end
local g_vars = data_Init()
if s then g_vars=s end  -- If save then restore it
local SetRandomSeed = function () local level = Game():GetLevel() if g_vars.GlobalSeed ~= level:GetDungeonPlacementSeed() then g_vars.GlobalSeed = level:GetDungeonPlacementSeed()  math.randomseed(g_vars.GlobalSeed) math.random();math.random();math.random(); end end
---------------------------------------------------------------------------------------------------------
-- --[[Krayz --]] SAVE related: You shall pass your way
local Minutes60fps = function(a) return a*60*60 end
local Secondes60fps = function(a) return a*60 end
local Minutes30fps = function(a) return a*60*30 end
local Secondes30fps = function(a) return a*30 end
local Sv_CollectibleSave = 0
local Mod_SaveIt_Timer = 0
--~ local NOFSAVE = 0 -- can recycle as emergency stop?
function _Mod:Mod_SaveMoreThanFramePerfect()
	if IsNewGame() and Isaac.HasModData(_Mod) then
		ResetSave()
		g_vars = data_Init()
		Mod_SaveIt_Timer = 0
		NOFSAVE = 0
		db_e = "Save reset"
	end
end
function _Mod:Mod_SaveIt_Minutes()
	local p = Isaac.GetPlayer(0)
	local SaveTriggered = false
	if p.FrameCount > 5 then
		if p.FrameCount == 6 then SetRandomSeed() Isaac.DebugString(tostring(g_vars.GlobalSeed)) end
		if Sv_CollectibleSave ~= p:GetCollectibleCount() and p.FrameCount % 30 == 0 then
			SaveTriggered = true
			Sv_CollectibleSave = p:GetCollectibleCount()
		end
		if Mod_SaveIt_Timer >= Minutes30fps(5) or SaveTriggered or ( (Input.IsActionPressed(12, 0) or Input.IsButtonPressed(256, 0) or Input.IsButtonPressed(342, 0)) and ( Mod_SaveIt_Timer >= Secondes30fps(10) or not Isaac.HasModData(_Mod)) ) then
			db_c = _save_(g_vars)
			Isaac.DebugString("Save by Timer or PressedButton or SaveTriggered")
			Mod_SaveIt_Timer = 0
			--NOFSAVE = NOFSAVE + 1
		end
	end
	Mod_SaveIt_Timer = Mod_SaveIt_Timer + 1
end
function _Mod:Mod_SaveIt_Level(Curses)
	local level = Game():GetLevel()
	SetRandomSeed()
	if level:GetAbsoluteStage() ~= 1 then
		db_c = _save_(g_vars)
		Isaac.DebugString("Save by Level")
		--NOFSAVE = NOFSAVE + 1
		Mod_SaveIt_Timer = 0
	end
	db_d = "SavedByLevel" .. "  " .. tostring(Curses)  .. " stage: " .. tostring(level:GetAbsoluteStage())
	return Curses
end
_Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, _Mod.Mod_SaveIt_Minutes);
_Mod:AddCallback(ModCallbacks.MC_POST_RENDER, _Mod.Mod_SaveMoreThanFramePerfect);
_Mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, _Mod.Mod_SaveIt_Level);
------------------------------------------------------------------------------------------------------------------------

db_a = g_vars
db_d = nil
function _Mod:Stillbirth_VarsInit() -- player ini
	if not g_vars then
		g_vars = data_Init()
	end
end
_Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,_Mod.Stillbirth_VarsInit)

local function IsFamiliarExists(FamVariant)
	local entities = Isaac.GetRoomEntities()
	for i=1, #entities do
		if entities[i].Type == 3 and entities[i].Variant == FamVariant then -- 3 = familiar flag
			return true
		end
	end
	return false
end

-- FamiliarProtectedSpawn
function _Mod:FamiliarProtectedSpawn() --
    local player = Isaac.GetPlayer(0)

	if player.FrameCount < 5 then -- Anti Multi familiar spawn at game restart: May still have some use in some rares cases
			--g_vars.legacy_spawned = IsFamiliarExists(Familiar.legacy_variant)
			g_vars.FAM_SunWukongExists = IsFamiliarExists(Familiars.SunWukong_Familiar_Variant)
			g_vars.FAM_BombBumExists = IsFamiliarExists(Familiars.FAM_BombBumFamiliarVariant)
			Isaac.DebugString("Multi familiar Protection")
    else
--[[
		if not g_vars.legacy_spawned and player:HasCollectible(Items.legacy_i) then -- Legacy
			local e = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, Familiar.legacy_variant, 0, player.Position, Vector(0, 0), player);
			e = e:GetSprite()
			e:Play("Float", true)
			g_vars.legacy_spawned = true;
		end
--]]
		if not g_vars.FAM_BombBumExists and player:HasCollectible(Items.FAM_BombBum_i) then -- BombBum
			local e = Isaac.Spawn(Familiars.FAM_BombBumFamiliar, Familiars.FAM_BombBumFamiliarVariant, 0, player.Position, Vector(0, 0), player)
			e:AddEntityFlags(1<<21) -- FLAG_DONT_OVERWRITE
			g_vars.FAM_BombBumExists = true
		end
		if not g_vars.FAM_SunWukongExists  and player:HasCollectible(Items.SunWukong_i) then -- SunWukong
			local e = Isaac.Spawn(3, Familiars.SunWukong_Familiar_Variant, 0, player.Position, Vector(0, 0), player)
			e:AddEntityFlags(1<<21) -- FLAG_DONT_OVERWRITE
			g_vars.FAM_SunWukongExists = true
		end
    end
end
_Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, _Mod.FamiliarProtectedSpawn)

function _Mod:rendertext()
	Isaac.RenderText("_load_a: " .. tostring(db_a), 100, 60, 255, 255, 255, 255)
	Isaac.RenderText("b: " .. tostring(db_b), 100, 70, 255, 255, 255, 255)
	Isaac.RenderText("c_save_: " .. tostring(db_c), 100, 80, 255, 255, 255, 255)
	Isaac.RenderText("d: " .. tostring(db_d), 100, 90, 255, 255, 255, 255)
	Isaac.RenderText("Mod_SaveIt_timer: " .. tostring(Mod_SaveIt_Timer .. "/" .. tostring(Minutes30fps(5))), 100, 100, 255, 255, 255, 255)
	Isaac.RenderText("Reset_e: " .. tostring(db_e), 100, 110, 255, 255, 255, 255)
	Isaac.RenderText("IsNewGame(): " .. tostring(IsNewGame()), 100, 120, 255, 255, 255, 255)
	Isaac.RenderText(": " .. tostring(dbz), 100, 130, 255, 255, 255, 255)
	Isaac.RenderText("NumOfSave: " .. tostring(NOFSAVE), 100, 140, 255, 255, 255, 255)
	Isaac.RenderText("blindPact_pickedItem: " .. tostring(g_vars.blindPact_pickedItem), 100, 150, 255, 255, 255, 255)
	Isaac.RenderText("blindPact_previousItem: " .. tostring(g_vars.blindPact_previousItem), 100, 160, 255, 255, 255, 255)
	Isaac.RenderText("GlobalSeed: " .. tostring(g_vars.GlobalSeed), 100, 170, 255, 255, 255, 255)
	Isaac.RenderText(": " .. tostring(db_z), 100, 180, 255, 255, 255, 255)
end
_Mod:AddCallback( ModCallbacks.MC_POST_RENDER, _Mod.rendertext )

--	##################################### Local Functions  ####################################

local function IsShooting(player) -- return if player is shooting(true) or not(false)
	if player:GetFireDirection() ~= -1 then
		return true
	else
		return false
	end
end

local function GetRange(player) -- Multby 12.5 for the InGame effective range (return a NEGATIVE value)
    local a = player.TearFallingAcceleration
    local h = player.TearHeight
    local v = player.ShotSpeed
    local range = a*h*h/(v*v*2)-h
    return -math.abs(range)
end

--::ShootCustomTear( TearVariant(Int), ShooterEntity(Entity), Player(Entity), DmgMult(float), VelMult(Positive Vector(n, n)), Bool_AddPlayerVel(Bool))
--::Return EntityTear
local function ShootCustomTear( TearVariant, ShooterEntity, Player, DmgMult, VelMult, Bool_AddEntityVel ) -- Custom Tears Shooting Function.
	local v = nil
	local VelMult = Vector( math.abs(VelMult.X), math.abs(VelMult.Y) )
	if Bool_AddEntityVel then
		v = Vector( Player:GetLastDirection().X*VelMult.X + (Player:GetVelocityBeforeUpdate().X*0.5), Player:GetLastDirection().Y*VelMult.Y + (Player:GetVelocityBeforeUpdate().Y*0.5) )
	else
		v = Vector( Player:GetLastDirection().X*VelMult.X, Player:GetLastDirection().Y*VelMult.Y  )
	end
	local customTear = Isaac.Spawn( 2, TearVariant, 0, ShooterEntity.Position, v, ShooterEntity ) -- 2 = EntityType Tear
	local Sprite = customTear:GetSprite()
	customTear.CollisionDamage = customTear.CollisionDamage * DmgMult
	Sprite:Play( Sprite:GetDefaultAnimation() , true )
	return customTear
end

local function PlayFamiliarShootAnimation(playerDir, Familiar)  -- Custom Familiar Shoot Animation Function
	local s = Familiar:GetSprite()
	local f = s:GetFrame()
	local framz_ = 14
	local framz_a = framz_ * 0.3
	s.PlaybackSpeed = 0.63

	if playerDir == 0 then -- left
		s.FlipX = true
		if not s:IsPlaying("FloatSide") and f >= framz_a then
			s:Play("FloatSide", true)
		elseif not s:IsPlaying("FloatShootSide") and f >= framz_ then
			s:Play("FloatShootSide", true)
		end
		s:Update()
	elseif playerDir == 1 then --up
		if not s:IsPlaying("FloatUp") and f >= framz_a then
			s:Play("FloatUp", true)
		elseif not s:IsPlaying("FloatShootUp") and f >= framz_ then
			s:Play("FloatShootUp", true)
		end
		s:Update()
	elseif playerDir == 2 then -- right
		s.FlipX = false
		if not s:IsPlaying("FloatSide") and f >= framz_a then
			s:Play("FloatSide", true)
		elseif not s:IsPlaying("FloatShootSide") and f >= framz_ then
			s:Play("FloatShootSide", true)
		end
		s:Update()
	elseif playerDir == 3 then --down
		if not s:IsPlaying("FloatDown") and f >= framz_a then
			s:Play("FloatDown", true)
		elseif not s:IsPlaying("FloatShootDown") and f >= framz_ then
			s:Play("FloatShootDown", true)
		end
		s:Update()
	else
		if not s:IsPlaying("FloatDown") and f >= framz_ then
			s:Play("FloatDown", true)
		end
	end
end

local devilPoolPassive = {8, 51, 67, 79, 80, 81, 82, 113, 114, 118, 122, 134, 159, 163, 172, 187, 212, 215, 216, 225, 230, 237, 241, 259, 262, 268, 269, 275, 278, 311, 412, 408, 399, 391, 360, 409, 433, 431, 420, 417, 498, 462, 442, 468}

--	###################################################################################


--	###############################################################################
--	###################################### ITEMS ###################################
--	################################### COLLECTIBLES ################################
--	#############################################################################

--[[
Active Item: "Cricket's Paw"
-Sliost-
--]]
function _Mod:UseCricketsPaw()
	local player = Isaac.GetPlayer(0)
	local soulHearts = player:GetSoulHearts()

	if g_vars.cricketsPaw_Uses < 5 then
		-- More than 3 read hearts
		if player:GetMaxHearts() > 4 or (player:GetMaxHearts() == 4 and (player:GetBlackHearts() > 1 or soulHearts() >1)) then
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

function _Mod:HasCricketsPawUsesCacheUpdate(player, cacheFlag)
	if g_vars.cricketsPaw_had then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			for i=1, g_vars.cricketsPaw_Uses do
				player.Damage = player.Damage * 1.1 -- TO BALANCE
			end
		end
	end
end
_Mod:AddCallback(ModCallbacks.MC_USE_ITEM, _Mod.UseCricketsPaw, Items.cricketsPaw_i)
_Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Mod.HasCricketsPawUsesCacheUpdate)

--[[
Passive item: "Money = Luck"
-Krayz-
--]]
function _Mod:MoneyLuck_obj()
	local player = Isaac.GetPlayer(0)
	if ( player:HasCollectible( Items.moneyLuck_i ) and g_vars.MoneyIsPower_OldCoins ~= player:GetNumCoins() ) then
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems(); g_vars.MoneyIsPower_OldCoins = player:GetNumCoins()
	end
end
function _Mod:MoneyLuck_UpdateStats(player, cacheFlag) --StatsUpdate Code
	local player = Isaac.GetPlayer(0)
	if ( player:HasCollectible( Items.moneyLuck_i ) ) then
		if cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck  = player.Luck + (player:GetNumCoins()*0.05048)
		end
	end
end
_Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, _Mod.MoneyLuck_obj);
_Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Mod.MoneyLuck_UpdateStats);

--[[
Active item: "Beer"
-Drazeb-
--]]
function _Mod:use_beer()
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
_Mod:AddCallback( ModCallbacks.MC_USE_ITEM, _Mod.use_beer, Items.Beer_i );

--[[
Passive item: "Brave Shoe"
-xahos-
--]]
function _Mod:take_damage(entity, dmg_amount, dmg_flag, dmg_src, dmg_countdown)
	local player = Isaac.GetPlayer(0)

	if player:HasCollectible(Items.brave_shoe_i) then
		if (dmg_flag == DamageFlag.DAMAGE_SPIKES) then
			return false
		end
	end
	return
end

function _Mod:cacheUpdate(player, cacheFlag)
	local player = Isaac.GetPlayer(0)

	if player:HasCollectible(Items.brave_shoe_i) then
		if (cacheFlag == CacheFlag.CACHE_SPEED) then
			player.MoveSpeed = player.MoveSpeed + 0.2;
		end
	end
end
_Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, _Mod.take_damage, EntityType.ENTITY_PLAYER)
_Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Mod.cacheUpdate)

--[[
Passive item : Technology 0 : un cercle qui s'agrandit quand on tire et qui suit isaac un peu comme tech X
-Dogeek & Krayz-
--]]
local function Tech_0_fire_lazer(player, radius) -- Shoot a TechX lazer centred on player with no velocity
    local tech0_lazer = player:FireTechXLaser(player.Position, Vector(0,0), radius)
    tech0_lazer:SetTimeout(3)
	return tech0_lazer
end

function _Mod:tech0_update()
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(Items.tech0_i) then
		local tech0_lazer = nil
		if not g_vars.tech0_oldFrame or g_vars.tech0_oldFrame < 0 then
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
    	if tech0_lazer and tech0_lazer.Radius < GetRange(player) * 12.0 then
        	g_vars.tech0_n = 1.0
    	end
    end
end
_Mod:AddCallback( ModCallbacks.MC_POST_UPDATE, _Mod.tech0_update);

--[[
Passive item : Hot Pizza Slice : Damage up, size up et 1 soul heart
-Dogeek-
--]]
function _Mod:hot_pizza_slice_cacheUpdate(player, cacheFlag)
	local player = Isaac.GetPlayer(0)

	if player:HasCollectible(Items.hot_pizza_slice_i) then
		if (cacheFlag == CacheFlag.CACHE_DAMAGE) then
			player.Damage = player.Damage + 1;
			--player.SpriteScale = player.SpriteScale * 1.2; -- Bug: reapplying if exit-reload game
			player:AddSoulHearts(2);
		end
	end
end
_Mod:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, _Mod.hot_pizza_slice_cacheUpdate);

--[[
Active item : Golden Idol : Donne un coeur bleugoldé
-Dogeek-
-K
--]]
function _Mod:GoldenIdol_onUse()
    local player = Isaac.GetPlayer(0)
    player:AddSoulHearts(2);
    player:AddGoldenHearts(1);
	return true
end
_Mod:AddCallback(ModCallbacks.MC_USE_ITEM, _Mod.GoldenIdol_onUse, Items.golden_idol_i);

--[[
Active item : Medusa's Head
-Azqswx-
--]]
function _Mod:medusaHead_use()

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
_Mod:AddCallback( ModCallbacks.MC_USE_ITEM, _Mod.medusaHead_use, Items.medusa_head_i );

--[[
Passive Item : Blind Pact : Missing No de DD donne un passif de DD aleatoire a chaque étage.
-Dogeek-
--]]

function _Mod:blindPactUpdate()
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
_Mod:AddCallback( ModCallbacks.MC_POST_UPDATE, _Mod.blindPactUpdate);

--[[
Passive Item: Solomon
Réduit la barre d'HP à 6 coeurs max mais gros boost de stats
-Dogeek
-Azqswx
--]]

function _Mod:SolomonCache(player, cacheFlag)
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(Items.solomon_i) then
        if cacheFlag == CacheFlag.CACHE_DAMAGE then --and cacheFlag == CacheFlag.CACHE_FIREDELAY and cacheFlag == CacheFlag.CACHE_SHOTSPEED and cacheFlag == CacheFlag.CACHE_LUCK and cacheFlag == CacheFlag.CACHE_SPEED then
            player.Damage = player.Damage + 2
            player.ShotSpeed = player.ShotSpeed + 0.6
            player.MaxFireDelay = player.MaxFireDelay - 3
            player.Luck = player.Luck + 3
            player.MoveSpeed = player.MoveSpeed + 0.3
        end
    end
end

function _Mod:SolomonUpdate()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(Items.solomon_i) then
    	local entities = Isaac.GetRoomEntities()
        local redHearts = player:GetMaxHearts()
        local soulHearts = player:GetSoulHearts()
        if (redHearts+soulHearts > 12) then
		    if (soulHearts ~= 0) then
		        player:AddSoulHearts(-2)
				for i = 1, #entities do
					local e = entities[i]
		    		if e.Type == 5 and e.Variant == 10 and (e.SubType == HeartSubType.HEART_SOUL or e.SubType == HeartSubType.HEART_HALF_SOUL or e.SubType == HeartSubType.HEART_BLACK) then
		        	e.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		    		end
		    	end
		    else
		       player:AddMaxHearts(-2, false)
		    end
		else
			for i = 1, #entities do
				local e = entities[i]
		    	if e.Type == 5 and e.Variant == 10 and (e.SubType == HeartSubType.HEART_SOUL or e.SubType == HeartSubType.HEART_HALF_SOUL or e.SubType == HeartSubType.HEART_BLACK) then
		        	e.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
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
_Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, _Mod.SolomonUpdate)
_Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Mod.SolomonCache)

--[[
Cataracte : Epiphora pour le dommage et le tear delay
--Dogeek
--]]

local numberOfTearsShot = 0
local previousDirection = -1
local baseDamage
local baseShotSpeed

local function numberToAdd()
	local cataractRate = 10
	if numberOfTearsShot <= 4*cataractRate then
		return math.floor(numberOfTearsShot/cataractRate)
	else
		return 4
	end
end

function _Mod:cataract_EvCache(player, cacheFlag)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.cataracte_i) then
		if IsShooting(player) then
			if cacheFlag == CacheFlag.CACHE_DAMAGE or cacheFlag == CacheFlag.CACHE_SHOTSPEED then
				player.Damage = player.Damage +  numberToAdd()
				player.ShotSpeed = player.ShotSpeed - 0.1*numberToAdd()
				if player:GetFireDirection() ~= previousDirection then
					numberOfTearsShot = 0
					player.Damage = baseDamage
					player.ShotSpeed = baseShotSpeed
				end
			end
		else
			numberOfTearsShot = 0
			player.Damage = baseDamage
			player.ShotSpeed = baseShotSpeed
		end
	end
end

function _Mod:cataract_PostUpdate()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.cataracte_i) then
		if not IsShooting(player) then
			baseDamage = player.Damage
			baseShotSpeed = player.ShotSpeed
		end
		if IsShooting(player) then
        	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        	player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
        	player:EvaluateItems()
			if (player.FrameCount%player.MaxFireDelay == 0) then
				numberOfTearsShot = numberOfTearsShot + 1
			end
		end
		previousDirection = player:GetFireDirection()
	end
end
_Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, _Mod.cataract_EvCache)
_Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, _Mod.cataract_PostUpdate)

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

function _Mod:BubblesHead_Update()
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()

	if player:HasCollectible(Items.BubblesHead_i) then
		if not g_vars.BubblesHead_oldFrame or g_vars.BubblesHead_oldFrame < 0 then
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
_Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, _Mod.BubblesHead_Update)

--------------------------------------------------------------------------------------------------
function _Mod:TearLeaf_MobSlowing( entity, damage, flag, source, countdown ) -- CustomTearEffect
	if entity and entity:IsVulnerableEnemy() then
		if source.Type == 2 and source.Variant == CustomEntities.TearLeaf_Variant then
		entity:AddEntityFlags( 1 << 7 ) -- Slow flag
		entity:SetColor( Color( 0.8, 0.8, 0.8, 0.85, 120, 120, 120 ), 9999, 50, false, false ) -- StopWatch like color
		end
	end
	return
end
_Mod:AddCallback( ModCallbacks.MC_ENTITY_TAKE_DMG, _Mod.TearLeaf_MobSlowing );
--------------------------------------------------------------------------------------------------

--	###############################################################################
--	##################################### FAMILIARS ##################################
--	###############################################################################

--[[
Krayz
Item : SunWukong (famillier) -- TODO?: Maybe make a Realign Familiars Function(annoying)
Tire de temps à autres une larme feuille qui stopwatch les ennemis
--]]
function _Mod:FAM_SunWukong_init(Familiar) -- init Familiar variables
	local FAM_SunWukongSprite = Familiar:GetSprite()
	Familiar.GridCollisionClass = GridCollisionClass.COLLISION_WALL
	FAM_SunWukongSprite:Play("FloatDown", true);
end

function _Mod:FAM_SunWukong_Update(Familiar) -- Familiar 'AI'
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()
	local ClosestB = nil
	local FAM_SunWukongSprite = Familiar:GetSprite()
	local FamiliarFrameCount = FAM_SunWukongSprite:GetFrame()
	local FamiliarFireDelay = 18

	if not g_vars.FAM_SunWukong_oldFrame or g_vars.FAM_SunWukong_oldFrame < 0 then
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
_Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, _Mod.FAM_SunWukong_init, Familiars.SunWukong_Familiar_Variant )
_Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, _Mod.FAM_SunWukong_Update, Familiars.SunWukong_Familiar_Variant )

--[[
Drazeb - Krayz
Item : Bomb Bum (famillier)
-- Spawn 1 random trinket every N(defined in the var:"g_vars.FAM_BombCounter") Bombs::
-- Work like the DarkBum: grab all the bombs he can in the room then come back to the player and spawn the trinket if he IsOkForIt.
--]]
function _Mod:FAMbb_BombBum_init(Familiar) -- init Familiar variables
    local FAMbb_BBSprite = Familiar:GetSprite()
    Familiar.GridCollisionClass = GridCollisionClass.COLLISION_WALL
    FAMbb_BBSprite:Play("FloatDown", true); -- Plays his float anim
end

function _Mod:FAMbb_BombBum_Update(Familiar) -- Familiar AI
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
    if ( (g_vars.FAM_BombCounter-g_vars.FAM_nBombBeforDrop) >= 0 and bval < 200 and not ClosestB ) or FAMbb_BBSprite:IsPlaying("PreSpawn") then -- Drop a Random Trinket every 10 Bombs when near player if no more bombs in the room
        if not FAMbb_BBSprite:IsPlaying("PreSpawn") and not FAMbb_BBSprite:IsPlaying("Spawn") then
            FAMbb_BBSprite:Play("PreSpawn", true)
        end
        if FamiliarFrameCount == 8 and not FAMbb_BBSprite:IsPlaying("Spawn") then -- Hum.IsOk.
            Isaac.Spawn(5, 350, 0, Familiar.Position, Vector(0, 0), player) -- Drop Rand Trinket
            g_vars.FAM_BombCounter = g_vars.FAM_BombCounter - g_vars.FAM_BombCounter
            if not FAMbb_BBSprite:IsPlaying("Spawn") then
                FAMbb_BBSprite:Play("Spawn", true)
            end
        end
    end
    if not FAMbb_BBSprite:IsPlaying("Spawn") and not FAMbb_BBSprite:IsPlaying("PreSpawn") and not FAMbb_BBSprite:IsPlaying("FloatDown") then
        FAMbb_BBSprite:Play("FloatDown", true)
    end
end
_Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, _Mod.FAMbb_BombBum_init, Familiars.FAM_BombBumFamiliarVariant )
_Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, _Mod.FAMbb_BombBum_Update, Familiars.FAM_BombBumFamiliarVariant )

--	###############################################################################
--	##################################### TRINKETS ###################################
--	###############################################################################

-- COMING SOON


--[[
db_a = nil
function _Mod:rendertext()
	Isaac.RenderText(": " .. tostring(db_a), 100, 60, 255, 255, 255, 255)
end
_Mod:AddCallback(ModCallbacks.MC_POST_RENDER, _Mod.rendertext)
--]]
