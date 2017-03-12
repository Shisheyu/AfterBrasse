--[[
Passive Item : Technology 0 : un cercle qui s'agrandit quand on tire et qui suit isaac un peu comme tech X
-Dogeek & Krayz-
--]]

local afterbrasse = RegisterMod("Afterbrasse", 1);
local tech0 = Isaac.GetItemIdByName("Technology 0");
local tech0_lazer = nil
local n = 1.0
local shootcnt = 0

local function IsShooting(player)
	if player:GetFireDirection() == -1 then
		return false
	else
		return true
	end
end
local function fire_tech_0(player, radius) -- * 12.50
    tech0_lazer = player:FireTechXLaser(player.Position, Vector(0,0), radius)
	local lazersprite = tech0_lazer:GetSprite()
	tech0_lazer:SetTimeout(3)
end

local function GetRange(player)
    local a = player.TearFallingAcceleration
    local h = player.TearHeight
    local v = player.ShotSpeed
    local range = a*h*h/(v*v*2)-h
    return -math.abs(range)
end

function afterbrasse:tech0_update()
    local player = Isaac.GetPlayer(0)
    if player.HasCollectible(tech0) then
    	if IsShooting(player) then
        	shootcnt = shootcnt + 1
        	if player.MaxFireDelay ==  shootcnt then
            		fire_tech_0( player, GetRange(player) )
            		tech0_lazer.Radius = tech0_lazer.Radius + GetRange(player) * n
            		tech0_lazer:SetMultidimensionalTouched(true)
            		n = n + player.ShotSpeed
            		shootcnt = 0
        	end
    	end
    	if tech0_lazer and tech0_lazer.Radius < GetRange(player) * 11.0 then
        	n = 1.0
    	end
    end
end

afterbrasse:AddCallback( ModCallbacks.MC_POST_UPDATE, afterbrasse.tech0_update);
