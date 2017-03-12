--[[
Trinket Green Cross : Challenge Down
--Dogeek
]]--

local afterbrasse = RegisterMod("Afterbrasse", 1);
local greenCross = Isaac.GetTrinketIdByName("Green Cross")
local lastRoom = nil

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
    return -math.abs(range)
end

function has_value (tab, val)
  for index, value in ipairs (tab) do
    if value == val then
      return true
    end
  end
  return false
end

local function IsShooting(player)
	if player:GetFireDirection() == -1 then
		return false
	else
		return true
	end
end

local function boolToInt(bool)
	if bool then
		return 1
	else
		return 0
	end
end

function afterbrasse:GreenCrossUpdate()
    local player = Isaac.GetPlayer(0)
    local entities = Isaac.GetRoomEntities()
    local room = Game():GetRoom()
    
    --if player:HasTrinket(greenCross) then
    	if lastRoom ~= room:GetDecorationSeed() then
    		for i=1, #entities do
    			local e = entities[i]
    			if e:IsVulnerableEnemy() then
    				if e:ToNPC():IsChampion() then
    					--Isaac.Spawn(e.Type, e.Variant, 0, e.Position, e.Velocity, e.SpawnerEntity) --essai de faire spawn le mob en normal avant d'enlver le champion, ne marche pas.
    					e:Remove() --comment changer un champion en non champion ? pour le moment supprime les mobs champions
    				end
    			end
    		end
    		lastRoom = room:GetDecorationSeed()
    	end
    --end
end

afterbrasse:AddCallback(ModCallbacks.MC_POST_UPDATE, afterbrasse.GreenCrossUpdate)
