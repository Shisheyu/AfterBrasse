--[[
Active item : Golden Idol : Donne un coeur goldé ou bleu
-Dogeek-
]]--

local afterbrasse = RegisterMod("Afterbrasse", 1);
local golden_idol = Isaac.GetItemIdByName("Golden Idol");

function afterbrasse:onGoldenIdolUse()
	local player = Isaac.GetPlayer(0)
	local randomNumber = RNG.RandomFloat();
	if randomNumber >= 0.5 then
		player.AddSoulHearts(2);
	else
		player.AddGoldenHearts(2);
	end
end

afterbrasse:AddCallback(ModCallbacks.MC_USE_ITEM, afterbrasse:onGoldenIdolUse, golden_idol);
