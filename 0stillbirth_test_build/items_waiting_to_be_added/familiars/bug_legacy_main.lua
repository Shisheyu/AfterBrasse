--[[
Passive Item : Legacy : 1up avec revive aléatoire entre les personnages
TO DO : Opti quand on aura la fonction pour de la fonction ItemListUpdate. On peut opti en ne stockant que le dernier passif pris par le joueur, ça évite la boucle de la mort. Opti en + : trigger la fonction
que dans les rooms a objet (god room, devil, item, shop et boss) mais c'est si on veut se faire chier (L'emmerdemment à son paroxysme dixit Krayz) : 1 1 1 1 1 1 1 1
Potentiellement quelques beugs avec la vie (si le dernier item passif pris est un HP UP, le HP UP se re triggerrera au moment du revive. Legacy revive dans la salle, on peut changer mais 1 1 1 1 1.
-Dogeek-
Krayz
]]--

local afterbrasse = RegisterMod("AfterBrasse", 1);
local legacy = Isaac.GetItemIdByName("Legacy_i");
local legacy_variant = Isaac.GetEntityVariantByName("Legacy");

local CustomItems = 1;
local TotalItems = CollectibleType.NUM_COLLECTIBLES + CustomItems; -- The barbaric way
local legacy_spawned = false; -- in player initialisaton callback -- need save
local lastRoom = nil; -- in player initialisaton callback


local function ItemListUpdate(player, list)
	for i = 1, ( TotalItems ) do
	   list[i] = player:HasCollectible(i);
	end
end

local function RestoreDeletedItem(It, IBackup, player)
	local sv = player.SpriteScale;
	for i = 1, (TotalItems) do
		if i ~= legacy and IBackup[i] ~= It[i] then
			player:AddCollectible(i, 1);
		end
	end
	player.SpriteScale = sv;
end

function afterbrasse:LegacyUpdate(fam)
	local player = Isaac.GetPlayer(0);
	local room = Game():GetRoom()
	local items = {};

	fam:FollowPosition(player.Position);
	if lastRoom ~= room:GetDecorationSeed() then -- Entering new room check
		ItemListUpdate(player, items);
		lastRoom = room:GetDecorationSeed()
	end
	if player:IsDead() and not player:WillPlayerRevive() then
		player:AddMaxHearts(-24);
		local charge = player:GetActiveCharge()
		local items_backup = {};
		ItemListUpdate(player, items_backup);
		local player_sprite = player:GetSprite()
		local PlayerFrame = player_sprite:GetFrame()
		if (not player_sprite:IsPlaying("Death")) then
		   player_sprite:Play("Death", true)
		end
		if PlayerFrame == 54 then
			player:Revive();
			player:AddBlackHearts(6)
			player:SetActiveCharge(0)
			player:UseActiveItem(482, false, false, false, false); -- clicker
			player:SetActiveCharge(charge)
			ItemListUpdate(player, items);
			player:SetMinDamageCooldown(120);
			player:AddHearts(24);
			RestoreDeletedItem(items, items_backup, player);
			legacy_spawned = false;
			player:RemoveCollectible(legacy);
			fam:Remove();
		end
	end
end

function afterbrasse:LegacyInit(fam)
	local player = Isaac.GetPlayer(0);
end

function afterbrasse:LegacyEvaluateCache(player, cacheFlag)
	local player = Isaac.GetPlayer(0);
	db_a = player:HasCollectible(legacy)
	db_b = legacy_spawned
	if not legacy_spawned and player:HasCollectible(legacy) then
		Isaac.Spawn(EntityType.ENTITY_FAMILIAR, legacy_variant, 0, player.Position, Vector(0, 0), player);
		legacy_spawned = true;
	end
end
afterbrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, afterbrasse.LegacyEvaluateCache);
afterbrasse:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, afterbrasse.LegacyInit, legacy_variant);
afterbrasse:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, afterbrasse.LegacyUpdate, legacy_variant);


function afterbrasse:rendertext()
	Isaac.RenderText(": " .. tostring(db_a), 100, 60, 255, 255, 255, 255)
	Isaac.RenderText(": " .. tostring(db_b), 100, 70, 255, 255, 255, 255)
end
afterbrasse:AddCallback(ModCallbacks.MC_POST_RENDER, afterbrasse.rendertext)
