--[[
Item Passive : Shockwaves! : dépendant de la luck du perso, fait spawn une onde de choc autour de lui quand il se fait toucher
--Dogeek
]]--

local afterbrasse = RegisterMod("Afterbrasse", 1);
--local testPassive = Isaac.GetItemIdByName("TestPassive")
local lastHearts = nil

local function hasTakenDamage(player)
	if player:GetHearts()<lastHearts then
		lastHearts = player:GetHearts()
		return true
	else
		return false
	end
end

function afterbrasse:ShockwaveUpdate()
    local player = Isaac.GetPlayer(0)
    if lastHearts == nil or lastHearts<player:GetHearts() then
    	lastHearts = player:GetHearts()
    end
    --if player:HasCollectible(testPassive) then
    	rand = math.random(-10, 40)
    	if hasTakenDamage(player) and rand <= player.Luck then
    		Isaac.Spawn(1000, EffectVariant.SHOCKWAVE, 0, player.Position, Vector(0,0), player)
    	end
    --end
end

afterbrasse:AddCallback(ModCallbacks.MC_POST_UPDATE, afterbrasse.ShockwaveUpdate)
