--[[
Item : Oddit
Type : Passive
By : Dogeek
Date : 2017-03-06
TODO : Adulthood et superbum ?
FIX : les actifs ne sont pas gardés en mémoire
]]--

local afterbrasse = RegisterMod("AfterBrasse", 1)
--local oddit = Isaac.GetItemIdByName("Oddit")
local oddit = 1
--local activeList = {}
-----------------------------
-- POST PLAYER INIT VARIABLES
-----------------------------
function afterbrasse:InitVariable(player)
	local pillGiven = false
end

afterbrasse:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,afterbrasse.InitVariable)

-----------------------------
-- POST UPDATE(@30FPS)
-----------------------------
local function hasTransfo(pool)
	local cnt = 0
	local player = Isaac.GetPlayer(0)
	local trigger = 3
	if player:HasCollectible(oddit) then
		trigger = 2
	end
	for i=1, #pool do
		--for j=1, #activeList do
		--	if pool[i] == activeList[j] then
		--		cnt = cnt + 1
		--	end
		--end
		if player:HasCollectible(pool[i]) then
			cnt = cnt + 1
		end
	end
	if cnt >= trigger then
		return true
	else
		return false
	end
end

function afterbrasse:OdditUpdate()
	local player = Isaac.GetPlayer(0)
	--if player:GetActiveItem() ~= nil then
	--	table.insert( activeList, player:GetCollectibleNum(player:GetActiveItem()))
	--end
	if player:HasCollectible(oddit) then
		local guppyPool = {145, 133, 81, 212, 134, 187}
		local beezlebubPool = {320, 272, 274, 279, 57, 128, 10, 248, 9, 264, 151, 148, 364, 365, 430, 426}
		local funGuyPool = {398, 71, 12, 120, 121, 11, 342}
		local seraphimPool = {33 , 185, 112, 184, 313, 173, 72 , 363, 101}
		local bobPool = {273, 42,  140, 149}
		local spunPool = {493, 496, 240, 70, 14, 143, 13, 345}
		local momPool = {102, 39, 41, 217, 55, 139, 110, 114, 30, 200, 228, 199, 31, 29, 195, 355, 508}
		local conjoinedPool = {8, 167, 169, 100, 322, 268, 67}
		local leviathanPool = {83, 79, 262, 80, 51, 159, 399 , 230, 118}
		local poopPool = {36 ,291, 236}
		local bookWormPool = {35, 65, 78, 34, 33, 97, 287, 58, 282, 292, 192}
		local spiderBabyPool = {288, 153, 211, 89, 171, 403}
		if not pillGiven then
			player:UsePill(PillEffect.PILLEFFECT_PUBERTY, PillColor.PILL_NULL)
			pillGiven = true
		end
		if hasTransfo(guppyPool) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_GUPPY)
		elseif hasTransfo(beezlebubPool) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES)
		elseif hasTransfo(funGuyPool) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_MUSHROOM) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_MUSHROOM)
		elseif hasTransfo(seraphimPool) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_ANGEL) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_ANGEL)
		elseif hasTransfo(bobPool) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_BOB) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_BOB)
		elseif hasTransfo(spunPool) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_DRUGS) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_DRUGS)
		elseif hasTransfo(momPool) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_MOM) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_MOM)
		elseif hasTransfo(conjoinedPool) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_BABY) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_BABY)
		elseif hasTransfo(leviathanPool) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_EVIL_ANGEL) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_EVIL_ANGEL)
		elseif hasTransfo(poopPool) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_POOP) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_POOP)
		elseif hasTransfo(bookWormPool) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_BOOK_WORM)
		elseif hasTransfo(spiderBabyPool) and not player:HasPlayerForm(PlayerForm.PLAYERFORM_SPIDERBABY) then
			player:AddPlayerFormCostume(PlayerForm.PLAYERFORM_SPIDERBABY)
		end
	end
end

afterbrasse:AddCallback(ModCallbacks.MC_POST_UPDATE, afterbrasse.OdditUpdate)
