--[[
Bob's Bitrex : spawn du creep en fonction de la range et de la luck du joueur
--Dogeek
]]--

local afterbrasse = RegisterMod("Afterbrasse", 1);
--local BobsBitrex = Isaac.GetItemIdByName("TestPassive")

function print(...)
    local str, sep = "", ""
    for i=1, select('#', ...) do
        str = str .. sep .. tostring(select(i, ...))
        sep = '\t'
    end
    return Isaac.DebugString(str)
end

local function GetRange(player)
    local a = player.TearFallingAcceleration
    local h = player.TearHeight
    local v = player.ShotSpeed
    local range = a*h*h/(v*v*2)-h
    return math.abs(range)
end

local function IsShooting(player)
	if player:GetFireDirection() == -1 then
		return false
	else
		return true
	end
end

local function SpawnCreep(player)
	local DirectionVector = player:GetAimDirection()
	local range = GetRange(player)*5
	local r = 36
	
	while r < range do
		local pos = player.Position + Vector(DirectionVector.X*r, DirectionVector.Y*r)
		local bite = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_GREEN, 0, pos, Vector(0,0), player):ToEffect()
		bite:SetTimeout(180)
		r = r+32
	end
end

function afterbrasse:BobsBitrexUpdate()
    local player = Isaac.GetPlayer(0)
    --if player:HasCollectible(BobsBitrex) then
    	if (Game():GetFrameCount()%player.MaxFireDelay == 0) then
			rand = math.random(-5, 45)
			if rand < player.Luck and IsShooting(player) then
				SpawnCreep(player)
			end
		end
    --end
end

afterbrasse:AddCallback(ModCallbacks.MC_POST_UPDATE, afterbrasse.BobsBitrexUpdate)
