--Mod
local AfterBrasse = RegisterMod("AfterBrasse", 1)
--items
local Items = {}
Items.CricketsPaw_i = Isaac.GetItemIdByName( "Cricket's Paw" )
Items.MoneyLuck_i = Isaac.GetItemIdByName( "Money = Luck" )
Items.Beer_i = Isaac.GetItemIdByName( "Beer" )

local DEBUG = 1 --debug/test or cheat mod flag
--[[--DEBUG/TEST PURPOSE CODE START HERE--]]
--[[
	- Fait spawn les items custom sur leurs piédestaux dans la salle de départ;
	- Si il n'y a pas de custom items, pas de spawn;
	- Donne le StarterDeck and Restock;
	- Fait spawn les cartes: Joker(DevilDeal), Hermit(Shop), EMPEROR(Boss) and Stars(ItemRoom);
	- Charge d'objet actif illimité;
	- Argent illimité + Coeurs illimités + Devil Deal illimité(restock automatique tous les N coeurs perdu) + GoldenKey + GoldenBomb;
	-Krayz-
--]]
if DEBUG then
	local INFINITE_MONEY = 1
	local ItemNumber = 0 --Don't change this unless you comment the line right under
	for i,k in pairs(Items) do ItemNumber = ItemNumber + 1 end
	local iDD = 10 -- Nombre d'objet dans le devil deal(à garder assez bas)
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

function AfterBrasse:VarsInit() -- Variables who need initialisation/reinitialisation at every new game
	cricketsPawUses = 0
	hadCricketsPaw = false
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

--[[
Item: "Money = Luck"  Type: "passive item"
-Krayz-
--]]
function AfterBrasse:MoneyLuck_obj()
	local player = Isaac.GetPlayer(0)
	if ( player:HasCollectible( Items.MoneyLuck_i ) ) then
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
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

--[[
Item: "Item" Type: "active item, passive item, trinket, familllier, etc"
-NomDuCodeur-
--]]



--CallBacks
--Vars Initialisation
AfterBrasse:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,AfterBrasse.VarsInit)
--Cricket'sPaw
AfterBrasse:AddCallback(ModCallbacks.MC_USE_ITEM, AfterBrasse.UseCricketsPaw, Items.CricketsPaw_i)
AfterBrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, AfterBrasse.HasCricketsPawUsesCacheUpdate)
--Money=Luck
AfterBrasse:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, AfterBrasse.MoneyLuck_obj);
AfterBrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, AfterBrasse.MoneyLuck_UpdateStats);
--Beer
AfterBrasse:AddCallback( ModCallbacks.MC_USE_ITEM, AfterBrasse.use_beer, Items.Beer_i );


