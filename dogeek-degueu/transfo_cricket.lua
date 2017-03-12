--[[
Item : transfo cricket
Type : transfo
By : Dogeek
Date : 2017-03-06
]]--

local afterbrasse = RegisterMod("AfterBrasse", 1)

----------------------------
-- GAME VARIABLES
----------------------------

local oddit = 1

-----------------------------
-- USEFUL FUNCTIONS
-----------------------------

function print(...)
    local str, sep = "", ""
    for i=1, select('#', ...) do
        str = str .. sep .. tostring(select(i, ...))
        sep = '\t'
    end
    return Isaac.DebugString(str)
end

local function hasTransfo(pool)
	local cnt = 0
	local player = Isaac.GetPlayer(0)
	local trigger = 3
	if player:HasCollectible(oddit) then
		trigger = 2
	end
	for i=1, #pool do
		if player:HasCollectible(pool[i]) then
			cnt = cnt + 1
		end
	end
	if cnt >= trigger then
		return true
	else
		return false
	end
end

local function getGrid()
	local room = Game():GetRoom()
	local grid = {}
	for i=1, room:GetGridWidth()*room:GetGridHeight() do
		if room:GetGridEntity(i) == nil then
			table.insert(grid, false)
		else
			table.insert(grid, room:GetGridEntity(i))
		end
	end
	return grid
end

local function MakeBridge(grid, rock_index, player, room)
	local direction = player:GetHeadDirection()
	if direction == Direction.LEFT then
		direction = -1
	elseif direction == Direction.RIGHT then
		direction = 1
	elseif direction == Direction.UP then
		direction = -room:GetGridWidth()
	elseif direction == Direction.DOWN then
		direction = room:GetGridWidth()
	else
		direction = 0
	end
	if grid[rock_index+direction] then
		if grid[rock_index+direction].Desc.Type == GridEntityType.GRID_PIT then
			local pit = grid[rock_index+direction]:ToPit()
			room:TryMakeBridge(pit)
		end
	end
end

function afterbrasse:cricketTransformUpdate()
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()
	local room = Game():GetRoom()
	local cricketPool = {4, 224}--, crickets_paw, crickets_leash, crickets_toys, crickets_tail}
	if hasTransfo(cricketPool) then
		player:AddCacheFlags(CacheFlag.CACHE_FLYING)
		player:EvaluateItems()
		local grid = getGrid()
		for i=1, #grid do
			local gridEntity = grid[i]
			if gridEntity  then
				local type_ = gridEntity.Desc.Type
				if type_==GridEntityType.GRID_ROCK or type_==GridEntityType.GRID_ROCKB or type_==GridEntityType.GRID_ROCKT or type_==GridEntityType.GRID_ROCK_BOMB or type_==GridEntityType.GRID_ROCK_ALT or type_==GridEntityType.GRID_ROCK_SS or type_==GridEntityType.GRID_POOP then
					if math.abs((player.Position - gridEntity.Position):Length()) <= 40 then
						gridEntity:Destroy()
						MakeBridge(grid, i, player, room)
					end
				end
			end
		end
	end
end

afterbrasse:AddCallback(ModCallbacks.MC_POST_UPDATE, afterbrasse.cricketTransformUpdate)

function afterbrasse:cricketTransformDamage(entity, dmg_amount, dmg_flag, dmg_src, dmg_countdown)
	local player = Isaac.GetPlayer(0)
	local MaxSpiderSpawned = 40
	local cricketPool = {4, 224}--, crickets_paw, crickets_leash, crickets_toys, crickets_tail}
	if hasTransfo(cricketPool) then
		if (dmg_flag == DamageFlag.DAMAGE_SPIKES) or dmg_flag == DamageFlag.DAMAGE_POOP or dmg_flag == DamageFlag.DAMAGE_ACID then
			return false
		end
	end
	if player:GetNumBlueSpiders() and player:GetNumBlueSpiders() <= MaxSpiderSpawned then
		if hasTransfo(cricketPool) and entity:IsVulnerableEnemy() and dmg_src.Type == 2 then
			player:AddBlueSpider(player.Position)
		end
	end
	return true
end
afterbrasse:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, afterbrasse.cricketTransformDamage);

function afterbrasse:cricketTransformCache(player, cacheFlag)
    local player = Isaac.GetPlayer(0)
    local cricketPool = {4, 224}--, crickets_paw, crickets_leash, crickets_toys, crickets_tail}
    if hasTransfo(cricketPool) then
        if cacheFlag == CacheFlag.CACHE_FLYING then
            player.CanFly = false
        end
    end
end
afterbrasse:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, afterbrasse.cricketTransformCache)
