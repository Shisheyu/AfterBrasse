--[[
Passive Item : Technology 0 : un cercle qui s'agrandit quand on tire et qui suit isaac un peu comme tech X
-Dogeek & Krayz-
--]]
--facteur de tech : x12.5
local afterbrasse = RegisterMod("Tech0", 1);
local tech0 = Isaac.GetItemIdByName("Technology 0");
local tech0_lazer = nil
local radius = 30

local function fire_tech_0(player, radius)
    tech0_lazer = player:FireTechXLaser(player.Position, Vector(0,0), radius)
    tech0_lazer:SetTimeout(3)
end

local function GetRange(player)
    local a = player.TearFallingSpeed
    local h = player.TearHeight
    local v = player.ShotSpeed
    local range = a*h*h/(v*v*2)+h
    return -range
end

local function GetInterval(player)
	local range = GetRange(player)
	local v = player.ShotSpeed
	local a = player.TearFallingSpeed
	local h = player.TearHeight
	local dt = range/v
	local dx = a*dt*dt/2 + v*dt
	return dx
end

function afterbrasse:tech0_update(player)
    local player = Isaac.GetPlayer(0)
    if radius >= range*12.5
	radius = 30
    else
	fire_tech_0(player, radius)
	radius = radius + GetInterval(player)
    end
end
afterbrasse:AddCallback( ModCallbacks.MC_POST_UPDATE, afterbrasse.tech0_update);

function afterbrasse:rendertext()
    local player = Isaac.GetPlayer(0)
    Isaac.RenderText(tostring(GetInterval(player)), 50, 100, 255, 255, 255, 255)
end
afterbrasse:AddCallback(ModCallbacks.MC_POST_RENDER, afterbrasse.rendertext)
