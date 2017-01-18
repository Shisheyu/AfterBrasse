-- CREATED BY ILLUDAY
-- illuday.deviantart.com
-- @illuday

------------- INCLUDE ILLUDAY'S LIB
local debug = require('debug');
local currentSrc = string.gsub(debug.getinfo(1).source, "^@?(.+/)[^/]+$", "%1") .. '?.lua';
package.path = currentSrc .. ';' .. package.path;
require('libs.illuday');

------------- MOD PASSIVE STATS UP

local Illuday = RegisterMod("Play with size", 1);
local spawn = false;
local item = Isaac.GetItemIdByName("illuday");

function Illuday:PlayerInit(player)
    spawn = false; end

function Illuday:Render(_mod)
    Isaac.RenderText("Illuday - #2 PLAY WITH SIZE", 80, 50, 255, 255, 255, 255);
    if not spawn then
        spawn = true;
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 511, Vector(320, 280), Vector(0, 0), player);
    end
end

------------- ITEM

function Illuday:ItemStats(player, cacheFlag)
  if player:HasCollectible(item) then
    if cacheFlag == CacheFlag.CACHE_TEARFLAG then
      player.TearFlags = TearFlags.FLAG_IPECAC;
    end;
  end
end

function Illuday:ItemPostUpdate()
  local player = Isaac.GetPlayer(0);
  
  if player:HasCollectible(item) then
    local entities = Isaac.GetRoomEntities()
    for i=0,#entities do
      
      if entities[i] ~= nil then
        local entity = entities[i];
        local frame = entity.FrameCount;

        if entity.Type == EntityType.ENTITY_TEAR and frame % 3 == 0 then
          entity.SpriteScale = Vector(math.random(7),math.random(7));
        end
      end
    end
    
    player.TearColor = Color(0,0,255,1,1,1,1);
    player.SpriteScale = Vector(2, 1);      
  end
end

Illuday:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Illuday.ItemStats);
Illuday:AddCallback(ModCallbacks.MC_POST_UPDATE, Illuday.ItemPostUpdate);

Illuday:AddCallback(ModCallbacks.MC_POST_RENDER, Illuday.Render);
Illuday:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Illuday.PlayerInit);

TearFlags = {
	FLAG_NO_EFFECT = 0,
	FLAG_SPECTRAL = 1,
	FLAG_PIERCING = 1<<1,
	FLAG_HOMING = 1<<2,
	FLAG_SLOWING = 1<<3,
	FLAG_POISONING = 1<<4,
	FLAG_FREEZING = 1<<5,
	FLAG_COAL = 1<<6,
	FLAG_PARASITE = 1<<7,
	FLAG_MAGIC_MIRROR = 1<<8,
	FLAG_POLYPHEMUS = 1<<9,
	FLAG_WIGGLE_WORM = 1<<10,
	FLAG_UNK1 = 1<<11, --No noticeable effect
	FLAG_IPECAC = 1<<12,
	FLAG_CHARMING = 1<<13,
	FLAG_CONFUSING = 1<<14,
	FLAG_ENEMIES_DROP_HEARTS = 1<<15,
	FLAG_TINY_PLANET = 1<<16,
	FLAG_ANTI_GRAVITY = 1<<17,
	FLAG_CRICKETS_BODY = 1<<18,
	FLAG_RUBBER_CEMENT = 1<<19,
	FLAG_FEAR = 1<<20,
	FLAG_PROPTOSIS = 1<<21,
	FLAG_FIRE = 1<<22,
	FLAG_STRANGE_ATTRACTOR = 1<<23,
	FLAG_UNK2 = 1<<24, --Possible worm?
	FLAG_PULSE_WORM = 1<<25,
	FLAG_RING_WORM = 1<<26,
	FLAG_FLAT_WORM = 1<<27,
	FLAG_UNK3 = 1<<28, --Possible worm?
	FLAG_UNK4 = 1<<29, --Possible worm?
	FLAG_UNK5 = 1<<30, --Possible worm?
	FLAG_HOOK_WORM = 1<<31,
	FLAG_GODHEAD = 1<<32,
	FLAG_UNK6 = 1<<33, --No noticeable effect
	FLAG_UNK7 = 1<<34, --No noticeable effect
	FLAG_EXPLOSIVO = 1<<35,
	FLAG_CONTINUUM = 1<<36,
	FLAG_HOLY_LIGHT = 1<<37,
	FLAG_KEEPER_HEAD = 1<<38,
	FLAG_ENEMIES_DROP_BLACK_HEARTS = 1<<39,
	FLAG_ENEMIES_DROP_BLACK_HEARTS2 = 1<<40,
	FLAG_GODS_FLESH = 1<<41,
	FLAG_UNK8 = 1<<42, --No noticeable effect
	FLAG_TOXIC_LIQUID = 1<<43,
	FLAG_OUROBOROS_WORM = 1<<44,
	FLAG_GLAUCOMA = 1<<45,
	FLAG_BOOGERS = 1<<46,
	FLAG_PARASITOID = 1<<47,
	FLAG_UNK9 = 1<<48, --No noticeable effect
	FLAG_SPLIT = 1<<49,
	FLAG_DEADSHOT = 1<<50,
	FLAG_MIDAS = 1<<51,
	FLAG_EUTHANASIA = 1<<52,
	FLAG_JACOBS_LADDER = 1<<53,
	FLAG_LITTLE_HORN = 1<<54,
	FLAG_GHOST_PEPPER = 1<<55
}