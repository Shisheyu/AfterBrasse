--[[
	Implementation of the A* pathfinding algorithm (from wikipedia)
	room: Room
	start: Vector
	target: Vector
	return: List(index -> gridIndex) | nil
]]

local PathFinding = {}

local GridTileType = {
	FREE = 0,
	OBSTACLE = 1,
	INVALID = 2
}

local function heuristic_bird(room, startIdx, targetIdx)
	return (room:GetGridPosition(startIdx) - room:GetGridPosition(targetIdx)):LengthSquared()
end

PathFinding.findPath = function(room, start, target)
	local startIdx = room:GetGridIndex(start)
	-- local targetIdx = room:GetGridIndex(Isaac.GetFreeNearPosition(target, 0))
	local targetIdx = room:GetGridIndex(target)
	-- First build a grid that can easily be accessed
	local grid = {} 
	-- Look at grid entities that might be obstacles
	-- for i=1, room:GetGridSize() do
	-- 	local ge = room:GetGridEntity(i)
	-- 	if ge then
	-- 		-- Not exhaustive...
	-- 		-- State==2 for rocks that have been destroyed
	-- 		-- State>=4 for poops that have been destroyed
	-- 		if ge.Desc.Type == GridEntityType.GRID_DECORATION or
	-- 			ge.Desc.Type == GridEntityType.GRID_NULL or
	-- 			ge.Desc.Type == GridEntityType.GRID_SPIDERWEB or
	-- 			(ge.Desc.Type == GridEntityType.GRID_POOP and ge.State >= 4) or
	-- 			(ge.Desc.Type == GridEntityType.GRID_ROCK and ge.State == 2) or
	-- 			(ge.Desc.Type == GridEntityType.GRID_ROCK_BOMB and ge.State == 2) or
	-- 			(ge.Desc.Type == GridEntityType.GRID_ROCK_SS and ge.State == 2) or
	-- 			(ge.Desc.Type == GridEntityType.GRID_ROCK_ALT and ge.State == 2) or
	-- 			(ge.Desc.Type == GridEntityType.GRID_ROCKB and ge.State == 2) or
	-- 			(ge.Desc.Type == GridEntityType.GRID_ROCKT and ge.State == 2) then
	-- 			grid[i] = GridTileType.FREE
	-- 		else
	-- 			grid[i] = GridTileType.OBSTACLE
	-- 		end
	-- 	else -- No GridEntity there
	-- 		if room:IsPositionInRoom(room:GetGridPosition(i), 0) then
	-- 			grid[i] = GridTileType.FREE
	-- 		else
	-- 			grid[i] = GridTileType.INVALID
	-- 		end
	-- 	end
	-- end
	-- -- Look at entities that might be obstacles
	-- local ee = Isaac.GetRoomEntities()
	-- for i=1, #ee do
	-- 	local e = ee[i]
	-- 	-- HitPoints>1 is for fires that have been put out
	-- 	if e.Type == EntityType.ENTITY_FIREPLACE and e.HitPoints > 1 then
	-- 		grid[room:GetGridIndex(e.Position)] = GridTileType.OBSTACLE
	-- 	end
	-- end
	for i=1, room:GetGridSize() do
		local col = room:GetGridCollision(i) -- how did i miss this function >_>
		if col == 0 then
			grid[i] = GridTileType.FREE
		else
			grid[i] = GridTileType.OBSTACLE
		end
	end

	local w = room:GetGridWidth()

	-- A*
	local success = false
	local closedSet = {} -- Set(gridIndex)
	local openSet = {} -- List(index -> gridIndex)
	openSet[1] = startIdx
	local cameFrom = {} -- Map(gridIndex -> gridIndex)
	local gScore = {} -- Map(gridIndex -> number)
	for i=1, #grid do
		gScore[i] = 99999999
	end
	gScore[startIdx] = 0
	local fScore = {} -- Map(gridIndex -> number)
	for i=1, #grid do
		fScore[i] = 99999999
	end
	fScore[startIdx] = heuristic_bird(room, startIdx, targetIdx)
	
	while #openSet > 0 do
		local current
		local current_openSetIndex
		local best_fScore = 99999999
		for i=1, #openSet do
			if fScore[openSet[i]] < best_fScore then
				current = openSet[i]
				current_openSetIndex = i
				best_fScore = fScore[openSet[i]]
			end
		end
		if current == targetIdx then
			success = true
			break
		end
		table.remove(openSet, current_openSetIndex)
		closedSet[current] = true
		local neighbors = {
			{idx=current-1, cost=1}, 
			{idx=current+1, cost=1}, 
			{idx=current-w, cost=1}, 
			{idx=current+w, cost=1},
		}
		for _,neigh in pairs(neighbors) do
			local n = neigh.idx
			if (grid[n] == GridTileType.FREE or n == targetIdx) and (closedSet[n] ~= true) then
				local tentative_gScore = gScore[current] + 1
				local in_openSet = false
				for i=1, #openSet do
					if openSet[i] == n then
						in_openSet = true
						break
					end
				end
				if (not in_openSet) or tentative_gScore < gScore[n] then
					openSet[#openSet+1] = n
					cameFrom[n] = current
					gScore[n] = tentative_gScore
					fScore[n] = gScore[n] + heuristic_bird(room, n, targetIdx)
				end
			end
		end
	end

	if success then
		local path = {}
		local count = 1
		local current = targetIdx
		while cameFrom[current] do
			current = cameFrom[current]
			count = count + 1
		end
		local current = targetIdx
		if grid[targetIdx] ~= GridTileType.FREE then
			count = count - 1
			current = cameFrom[targetIdx]
		end
		while current do
			path[count] = current
			count = count - 1
			current = cameFrom[current]
		end
		return path
	else
		return nil
	end

end

return PathFinding