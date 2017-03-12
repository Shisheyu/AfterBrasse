local _Mod = RegisterMod("test", 1)
--local bitrex_i = Isaac.GetItemIdByName("Bitrex");

local BitUp={};
local BitDown={};
local BitRight={};
local BitLeft={};
local initLeft = true;
local initUp = true;
local initRight = true;
local initDown = true;

local function GetRange(player)
    local player = Isaac.GetPlayer(0);
    local a = player.TearFallingAcceleration;
    local h = player.TearHeight;
    local v = player.ShotSpeed;
    local range = a*h*h/(v*v*2)-h;
    return math.abs(range)
end

function _Mod:onPlayerInit()
    initLeft = false;
    initUp = false;
    initRight = false;
    initDown = false;
end

_Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, _Mod.onPlayerInit)


function _Mod:onUpdateBitrex()
    local player = Isaac.GetPlayer(0);
    range = GetRange(player);
    local n = 1+math.abs(range/10);
    --if player:HasCollectible(bitrex_i) then
        local rng = math.random(-2,100);
        if rng <= player.Luck or initDown == false then 
            if player:GetFireDirection() == 0 or initLeft == false then
                BitLeft1 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, Vector(player.Position.X-32,player.Position.Y), Vector(0,0),player);
                initLeft = true;
            elseif player:GetFireDirection() == 1 or initUp == false then
                BitUp1 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, Vector(player.Position.X,player.Position.Y-32), Vector(0,0),player);
                initUp = true;
            elseif player:GetFireDirection() == 2 or initRight == false then
                BitRight1 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, Vector(player.Position.X+32,player.Position.Y), Vector(0,0),player);
                initRight = true;
            elseif player:GetFireDirection() == 3 or initDown == false then
                BitDown1 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, Vector(player.Position.X,player.Position.Y+32), Vector(0,0),player);
                initDown = true;
            end
        end
        if BitLeft1.FrameCount == 3 then
            BitLeft[2] = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, Vector(BitLeft1.Position.X-32,BitLeft1.Position.Y), Vector(0,0),player);
        elseif BitUp1.FrameCount == 3 then
            BitUp[2] = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, Vector(BitUp1.Position.X,BitUp1.Position.Y-32), Vector(0,0),player);
        elseif BitRight1.FrameCount == 3 then
            BitRight[2] = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, Vector(BitRight1.Position.X+32,BitRight1.Position.Y), Vector(0,0),player);
        elseif BitDown1.FrameCount == 3 then
            BitDown[2] = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, Vector(BitDown1.Position.X,BitDown1.Position.Y+32), Vector(0,0),player);
        end
        for i = 2, n do
            if BitLeft[i].FrameCount == 3 then
                BitLeft[i+1] = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, Vector(BitLeft[i].Position.X-32,BitLeft[i].Position.Y), Vector(0,0),player);
            elseif BitUp[i].FrameCount == 3 then
                BitUp[i+1] = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, Vector(BitUp[i].Position.X,BitUp[i].Position.Y-32), Vector(0,0),player);
            elseif BitRight[i].FrameCount == 3 then
                BitRight[i+1] = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, Vector(BitRight[i].Position.X+32,BitRight[i].Position.Y), Vector(0,0),player);
            elseif BitDown[i].FrameCount == 3 then
                BitDown[i+1] = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, Vector(BitDown[i].Position.X,BitDown[i].Position.Y+32), Vector(0,0),player);
            end
        end
    --end
end
_Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, _Mod.onUpdateBitrex)
