-- CREATED BY ILLUDAY
-- illuday.deviantart.com
-- @illuday


------------- INCLUDE ILLUDAY'S LIB
local debug = require('debug');
local currentSrc = string.gsub(debug.getinfo(1).source, "^@?(.+/)[^/]+$", "%1") .. '?.lua';
package.path = currentSrc .. ';' .. package.path;
require('libs.illuday');

------------- MOD PASSIVE STATS UP

local Illuday = RegisterMod("Play with tears", 1);
local spawn = false;
local item = Isaac.GetItemIdByName("illuday");

function Illuday:PlayerInit(player)
    spawn = false; end

function Illuday:Render(_mod)
    Isaac.RenderText("Illuday - #3 PLAY WITH TEARS", 80, 50, 255, 255, 255, 255);
    if not spawn then
        spawn = true;
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 511, Vector(320, 280), Vector(0, 0), player);
    end
end

------------- ITEM

--require('mobdebug').start()

local tearAdded = {}; 

--direction vertical - horizontal
function FireTears(player, position, direction)
  local firstVector;
  local secondVector
  if direction == "vertical" then
    firstVector = Vector(0,-10);
    secondVector = Vector(0,10);
  elseif direction == "horizontal" then
    firstVector = Vector(10,0);
    secondVector = Vector(-10,0);
  end
    
    local newTear = player:FireTear(position, firstVector, false, false, false);
    newTear.Color= Color(0,50,80,1,1,1,1);
    tearAdded[newTear.Index] = newTear.Index;
    local newTear = player:FireTear(position, secondVector, false, false, false);
    newTear.Color= Color(0,255,0,1,1,1,1);
    tearAdded[newTear.Index] = newTear.Index;
end

function Illuday:ItemPostUpdate()
  local player = Isaac.GetPlayer(0);
  
  if player:HasCollectible(item) then
    local entities = Isaac.GetRoomEntities()
    for i=0,#entities do
      
      if entities[i] ~= nil then
        local entity = entities[i];
        local frame = entity.FrameCount;

        if entity.Type == EntityType.ENTITY_TEAR then
          if not tearAdded[entity.Index] then
            
            if frame == 1 then
              entity.SpriteScale = Vector(5,5)
            end
            
            if frame % 5 == 0 then
              local aimDirection = entity.Velocity
              local tearsDirection;
              
              if math.abs(aimDirection.X) > math.abs(aimDirection.Y) then
                tearsDirection = "vertical";
              else
                tearsDirection = "horizontal";
              end
            
              FireTears(player, entity.Position, tearsDirection);
              entity.SpriteScale = Vector(entity.SpriteScale.X-1,entity.SpriteScale.Y-1);
            end
          end
        end
      end
    end
  end
end



Illuday:AddCallback(ModCallbacks.MC_POST_UPDATE, Illuday.ItemPostUpdate);

Illuday:AddCallback(ModCallbacks.MC_POST_RENDER, Illuday.Render);
Illuday:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Illuday.PlayerInit);
