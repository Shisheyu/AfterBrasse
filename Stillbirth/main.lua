--[[
CodeName AfterBrasse
ModName: Stillbirth
]]

local math = math
local _Mod = RegisterMod("Stillbirth", 1)

local Items =	{
						MoneyLuck_i = Isaac.GetItemIdByName( "Money = Luck" ),
						Beer_i = Isaac.GetItemIdByName( "Dad's Beer" ),
						brave_shoe_i = Isaac.GetItemIdByName( "Brave Shoe" ),
						tech0_i = Isaac.GetItemIdByName("Technology 0"),
						hot_pizza_slice_i = Isaac.GetItemIdByName("Hot Pizza Slice"),
						golden_idol_i = Isaac.GetItemIdByName("Golden Idol"),
						medusa_head_i = Isaac.GetItemIdByName("Medusa's Head")
					}
local g_vars =	{
						MoneyIsPower_OldCoins = 0,
						tech0_shootcnt = 0,
						tech0_n = 1.0,
						tech0_lazer = nil,
						tech0_OldRoom = nil,
						HasHot_pizza_slice = false
					}

--	################################### Local Functions #################################

local function IsShooting(player) -- return if player is shooting(true) or not(false)
	if player:GetFireDirection() == -1 then
		return false
	else
		return true
	end
end

local function IsFamiliarExists(FamId)
	local entities = Isaac.GetRoomEntities()
	for i=1, #entities do
		if entities[i].Type == 3 and entities[i].Variant == FamId then -- 3 = familiar flag
			return true
		end
	end
	return false
end

local function GetRange(player) -- Multby 12.5 for the InGame effective range (return a NEGATIVE value)
    local a = player.TearFallingAcceleration
    local h = player.TearHeight
    local v = player.ShotSpeed
    local range = a*h*h/(v*v*2)-h
    return -math.abs(range)
end
--	###############################################################################

function _Mod:VarsInit() -- Variables who need initialisation/reinitialisation at every new game
	g_vars.MoneyIsPower_OldCoins = Isaac.GetPlayer(0):GetNumCoins()
	--
	g_vars.tech0_shootcnt = 0
	g_vars.tech0_n = 1.0
	g_vars.tech0_lazer = nil
	g_vars.tech0_OldRoom = nil
	--
end
_Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,_Mod.VarsInit)

--	###############################################################################
--	################################### COLLECTIBLES #################################
--	###############################################################################

--[[
Passive item: "Money = Luck"
-Krayz-
--]]
function _Mod:MoneyLuck_obj()
	local player = Isaac.GetPlayer(0)
	if ( player:HasCollectible( Items.MoneyLuck_i ) and g_vars.MoneyIsPower_OldCoins ~= player:GetNumCoins() ) then
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems(); g_vars.MoneyIsPower_OldCoins = player:GetNumCoins()
	end
end
function _Mod:MoneyLuck_UpdateStats(player, cacheFlag) --StatsUpdate Code
	local player = Isaac.GetPlayer(0)
	if ( player:HasCollectible( Items.MoneyLuck_i ) ) then
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
local function Tech_0_fire_lazer(player, radius) -- [ Tech_0 Function ] Shoot a TechX lazer centred on player with no velocity
    g_vars.tech0_lazer = player:FireTechXLaser(player.Position, Vector(0,0), radius)
    g_vars.tech0_lazer:SetTimeout(3)
end

function _Mod:tech0_update()
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(Items.tech0_i) then
    	if IsShooting(player) then
        	g_vars.tech0_shootcnt = g_vars.tech0_shootcnt + 1
        	if player.MaxFireDelay ==  g_vars.tech0_shootcnt then
            		Tech_0_fire_lazer( player, GetRange(player) )
            		g_vars.tech0_lazer.Radius = g_vars.tech0_lazer.Radius + GetRange(player) * g_vars.tech0_n
            		g_vars.tech0_lazer:SetMultidimensionalTouched(1)
            		g_vars.tech0_n = g_vars.tech0_n + player.ShotSpeed
            		g_vars.tech0_shootcnt = 0
        	end
    	end
    	if g_vars.tech0_lazer and g_vars.tech0_lazer.Radius < GetRange(player) * 11.0 then
        	g_vars.tech0_n = 1.0
    	end
    end
end
_Mod:AddCallback( ModCallbacks.MC_POST_UPDATE, _Mod.tech0_update);

--[[
Passive item : Hot Pizza Slice : Damage up, size up et 1 soul heart
-Dogeek-
]]--

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
]]--
function _Mod:GoldenIdol_onUse()
    local player = Isaac.GetPlayer(0)
    player:AddSoulHearts(2);
    player:AddGoldenHearts(1);
end
_Mod:AddCallback(ModCallbacks.MC_USE_ITEM, _Mod.GoldenIdol_onUse, Items.golden_idol_i);

--[[
Active item : Medusa's Head
-Azqswx-
]]--
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
end
_Mod:AddCallback( ModCallbacks.MC_USE_ITEM, _Mod.medusaHead_use, Items.medusa_head_i );



--	###############################################################################
--	##################################### TRINKETS ###################################
--	###############################################################################

-- COMING SOON


--	###############################################################################
--	##################################### FAMILIARS ##################################
--	###############################################################################

-- COMING SOON

--[[
db_a = nil
function _Mod:rendertext()
	Isaac.RenderText(": " .. tostring(db_a), 100, 60, 255, 255, 255, 255)
end
_Mod:AddCallback(ModCallbacks.MC_POST_RENDER, _Mod.rendertext)
--]]
