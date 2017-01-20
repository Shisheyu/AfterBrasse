--[[
Temp main till we can use external source files without the --luadebug
]]

--Mod
local AfterBrasse = RegisterMod("AfterBrasse", 1)
--items
local Items =	{
						CricketsPaw_i = Isaac.GetItemIdByName( "Cricket's Paw" ),
						MoneyLuck_i = Isaac.GetItemIdByName( "Money = Luck" ),
						Beer_i = Isaac.GetItemIdByName( "Beer" ),
						brave_shoe_i = Isaac.GetItemIdByName( "Brave Shoe" )
					}
local DEBUG = 1 --debug/test or cheat mod flag
--[[--DEBUG/TEST PURPOSE CODE START HERE--]]
--[[
	- Fait spawn les items custom sur leurs piedestaux dans la salle de depart;
	- Si il n'y a pas de custom items, pas de spawn;
	- Donne le StarterDeck and Restock;
	- Fait spawn les cartes: Joker(DevilDeal), Hermit(Shop), EMPEROR(Boss) and Stars(ItemRoom);
	- Charge d'objet actif illimite;
	- Argent illimite + Coeurs illimites + Devil Deal illimite(restock automatique tous les N coeurs perdu) + GoldenKey + GoldenBomb;
	-Krayz-
--]]
if DEBUG then
	local INFINITE_MONEY = 1
	local ItemNumber = 0 --Don't change this unless you comment the line right under
	for i,k in pairs(Items) do ItemNumber = ItemNumber + 1 end
	local iDD = 10 -- Nombre d'objet dans le devil deal(a garder assez bas)
	local cartes = {5,10,18,31}
	local DoneD = 0
	local cnt = 0
	local Item = 510

	function AfterBrasse:TestInit()
		local player = Isaac.GetPlayer(0)
		local room = Game():GetRoom()
		local entities = Isaac.GetRoomEntities()

		if (player.FrameCount == 1) then
			DoneD = 0
			cnt = 0
			Item = 511
			player:AddCollectible(251, 1); player:AddCollectible(376, 1); player:AddGoldenBomb(); player:AddGoldenKey(); player:DonateLuck(50);
		elseif (player.FrameCount == 5) then
			CleanRoom(entities);
			for i = 1, ItemNumber do
				local pos = Isaac.GetFreeNearPosition(player.Position, 100); Isaac.Spawn(5, 100, Item , pos , Vector(0, 0), player); Item = Item + 1;
			end
			for i = 1, #cartes do
				local pos = Isaac.GetFreeNearPosition(player.Position, 100); Isaac.Spawn(5, 300,  cartes[i], pos , Vector(0, 0), player);
			end
		elseif( room:GetType() == 14 and DoneD == 0 ) then
			CleanRoom(entities);
			for i = 1, iDD do
				local pos = Isaac.GetFreeNearPosition(player.Position, 100); Isaac.Spawn(5, 150, 0 , pos , Vector(0, 0), player);
			end
			DoneD = 1
		end
		if (player.FrameCount % 30) == 0 then
			if not player:FullCharge() then
				player:SetActiveCharge(12)
			end
			if player:GetNumCoins() < 99 and INFINITE_MONEY then
				player:AddCoins(99)
			end
			if (player:GetHearts() < 24) then
				player:AddMaxHearts(24, 1); player:AddHearts(24);
				if room:GetType() == 14 then
					cnt = cnt +1
					if cnt == math.ceil(iDD/2) then
						DoneD = 0; cnt = 0;
					end
				end
			end
		end
	end
	CleanRoom = function(entities)	for i = 1, #entities do if i ~= 1 then entities[i].Remove(entities[i]) end end end
	AfterBrasse:AddCallback(ModCallbacks.MC_POST_UPDATE, AfterBrasse.TestInit);
end
--[[
function AfterBrasse:debug_text()
	Isaac.RenderText(tostring(ItemNumber), 200, 25, 255, 255, 255, 255)
	Isaac.RenderText(tostring(debug_text2), 200, 35, 255, 255, 255, 255)
	Isaac.RenderText(tostring(debug_text3), 200, 45, 255, 255, 255, 255)
end
--debug
AfterBrasse:AddCallback(ModCallbacks.MC_POST_RENDER, AfterBrasse.debug_text)
--]]

--[[--DEBUG/TEST PURPOSE CODE END HERE--]]

--local global vars
local cricketsPawUses = 0
local hadCricketsPaw = false
local OldCoins = 0

function AfterBrasse:VarsInit() -- Variables who need initialisation/reinitialisation at every new game
	cricketsPawUses = 0
	hadCricketsPaw = false
	OldCoins = 0
end

--[[
Item: "Cricket's Paw" Type: "active item"
-Sliost-
--]]
function AfterBrasse:UseCricketsPaw()
  local player = Isaac.GetPlayer(0)
  local soulHearts = player:GetSoulHearts()

  if cricketsPawUses < 5 then
    -- More than 3 read hearts
    if player:GetMaxHearts() > 4 or (player:GetMaxHearts() == 4 and (player:GetBlackHearts() > 1 or soulHearts() >1)) then
      player:AddMaxHearts(-4)
      hadCricketsPaw = true
      cricketsPawUses = math.min(cricketsPawUses + 1,5)
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
      return true
    -- More than 3 full soul/black hearts
    elseif (player:GetMaxHearts() == 0 and soulHearts() > 6) or (player:GetMaxHearts() ~= 0 and soulHearts >= 6) then
      for i=1,6 do
        player:RemoveBlackHeart(soulHearts -i)
      end
      player:AddSoulHearts(-6)
      hadCricketsPaw = true
      cricketsPawUses = math.min(cricketsPawUses + 1,5)
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
      return true
    end
  end
end

function AfterBrasse:HasCricketsPawUsesCacheUpdate(player, cacheFlag)
  if hadCricketsPaw then
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
      for i=1, cricketsPawUses do
        player.Damage = player.Damage * 1.1 -- TO BALANCE
      end
    end
  end
end
AfterBrasse:AddCallback(ModCallbacks.MC_USE_ITEM, AfterBrasse.UseCricketsPaw, Items.CricketsPaw_i)
AfterBrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, AfterBrasse.HasCricketsPawUsesCacheUpdate)

--[[
Item: "Money = Luck"  Type: "passive item"
-Krayz-
--]]
function AfterBrasse:MoneyLuck_obj()
	local player = Isaac.GetPlayer(0)
	if ( player:HasCollectible( MoneyLuck_i ) and OldCoins ~= player:GetNumCoins() ) then
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems(); OldCoins = player:GetNumCoins()
	end
end
function AfterBrasse:MoneyLuck_UpdateStats(player, cacheFlag) --StatsUpdate Code
	local player = Isaac.GetPlayer(0)
	if ( player:HasCollectible( Items.MoneyLuck_i ) ) then
		if cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck  = player.Luck + (player:GetNumCoins()*0.05048)
		end
	end
end
AfterBrasse:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, AfterBrasse.MoneyLuck_obj);
AfterBrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, AfterBrasse.MoneyLuck_UpdateStats);

--[[
Item: "Beer" Type: "active item"
-Drazeb-
--]]
function AfterBrasse:use_beer()
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
AfterBrasse:AddCallback( ModCallbacks.MC_USE_ITEM, AfterBrasse.use_beer, Items.Beer_i );

--[[
Item: "Brave Shoe" Type: "passive item"
-xahos-
--]]
function AfterBrasse:take_damage(entity, dmg_amount, dmg_flag, dmg_src, dmg_countdown)
  local player = Isaac.GetPlayer(0)

  if player:HasCollectible(Items.brave_shoe_i) then
    if (dmg_flag == DamageFlag.DAMAGE_SPIKES) then
      return false
    end
  end
  return true
end

function AfterBrasse:cacheUpdate(player, cacheFlag)
  local player = Isaac.GetPlayer(0)

  if player:HasCollectible(Items.brave_shoe_i) then
    if (cacheFlag == CacheFlag.CACHE_SPEED) then
      player.MoveSpeed = player.MoveSpeed + 0.2;
    end
  end
end
AfterBrasse:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, AfterBrasse.take_damage, EntityType.ENTITY_PLAYER)
AfterBrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, AfterBrasse.cacheUpdate)

--Vars Initialisation
AfterBrasse:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,AfterBrasse.VarsInit)


