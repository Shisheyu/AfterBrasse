--[[
Passive Item : Blind Pact : Missing No de DD donne un passif de DD aleatoire a chaque étage.
-Dogeek-
]]--

afterbrasse = RegisterMod("Afterbrasse", 1);
blindPact = Isaac.GetItemIdByName("Blind Pact");

local devilPoolPassive = {8, 51, 67, 79, 80, 81, 82, 113, 114, 118, 122, 134, 159, 163, 172, 187, 212, 215, 216, 225, 230, 237, 241, 259, 262, 268, 269, 275, 278, 311, 412, 408, 399, 391, 360, 409, 433, 431, 420, 417, 498, 462, 442, 468}
local pickedItem = 0
local previousItem = 0
local currentStage
local previousStage = 0

function afterbrasse:blindPactUpdate(player)
	local player = Isaac.GetPlayer(0)
	--if player:HasCollectible(blindPact) then
		currentStage = Game():GetLevel():GetStage()
		if previousStage ~= currentStage then
			previousStage = currentStage
			local rand = math.random(#devilPoolPassive)
			pickedItem = devilPoolPassive[rand]
			player:AddCollectible(pickedItem, 0, true)
			if (previousItem ~= 0) and player:HasCollectible(previousItem) then
				player:RemoveCollectible(previousItem)
			end
		else
			previousItem = pickedItem
		end
	--end
end

afterbrasse:AddCallback( ModCallbacks.MC_POST_UPDATE, afterbrasse.blindPactUpdate);
