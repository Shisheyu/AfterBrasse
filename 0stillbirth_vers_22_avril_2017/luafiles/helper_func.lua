--	##################################### Local Functions  ####################################

function FreezeGame(duration)
	g_vars.framecount_stop = Game():GetFrameCount() + duration
	g_vars.freezeentities_init = 1
end

function FreezeGame2(duration, source)
	local entities = Isaac.GetRoomEntities()
	source = source or EntityRef(Isaac.GetPlayer(0))
	for i=1,#entities do
		entities[i]:AddFreeze(source, duration)
	end
	g_vars.framecount_stop = Game():GetFrameCount() + duration
end

function printTable(tbl)
	local s = ""
	for i=1, #tbl do s = s..tostring(tbl[i])..";" end
	print(s)
	return s
end

function printVector(vec)
	print("X coord:", vec.X)
	print("Y coord:", vec.Y)
	print("-------")
end

function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function RenderText(...)
    local str, sep = "", ""
	for i=1, select('#', ...) do
		str = str .. sep .. tostring(select(i, ...))
		sep = '\t'
	end
	Isaac.RenderText(str, 100, 100, 255, 255, 255, 255)
end

function IsShooting(player) -- return if player is shooting(true) or not(false)
	return (player:GetFireDirection() ~= -1)
end

function IsFullBlackHearts(player)  -- Usefull use of GetBlackHeart()
	return (function(n) local s = player:GetSoulHearts() for i=0, 12 do if (1<<i)-1 == n then return ((i*2)==s and true) or false end end return false end)( player:GetBlackHearts() )
end

function IsFullBlackHearts2(player)
	black = player:GetBlackHearts()
	soul = player:GetSoulHearts()
	return black == 2^soul
end

function GetRange(player) -- Multby 12.5 for the InGame effective range (return a NEGATIVE value)
    local a = player.TearFallingAcceleration
    local h = player.TearHeight
    local v = player.ShotSpeed
    local range = a*h*h/( v*v*2 ) - h
    return -math.abs( range )
end

--~ t = elapsed time; b = begin; c = change == ending - beginning; d = duration (total time)
function outBounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then
    return c * (7.5625 * t * t) + b
  elseif t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  else
    t = t - (2.625 / 2.75)
    return c * (7.5625 * t * t + 0.984375) + b
  end
end

--~ VectorLerp: a = vector pos1 ; b = vector pos2 ; p = float percent 0.0 - 1.0
function vLerp(a, b, p) return a:__add( ( (b:__sub(a)) * p ) ) end

--~ t = elapsed time; b = begin; c = change == ending - beginning; d = duration (total time)
function inQuad(t, b, c, d) return c * ((t / d) ^ 2) + b end

--::ShootCustomTear( TearVariant(Int), ShooterEntity(Entity), Player(Entity), DmgMult(float), VelMult(Positive Vector(n, n)), Bool_AddPlayerVel(Bool))
--::Return EntityTear
function ShootCustomTear( TearVariant, ShooterEntity, Player, DmgMult, VelMult, Bool_AddEntityVel ) -- Custom Tears Shooting Function.
	local v = nil
	local VelMult = Vector( math.abs(VelMult.X), math.abs(VelMult.Y) )
	if Bool_AddEntityVel then
		v = Vector( Player:GetLastDirection().X*VelMult.X + ( Player:GetVelocityBeforeUpdate().X*0.5 ), Player:GetLastDirection().Y*VelMult.Y + ( Player:GetVelocityBeforeUpdate().Y*0.5 ) )
	else
		v = Vector( Player:GetLastDirection().X*VelMult.X, Player:GetLastDirection().Y*VelMult.Y )
	end
	local customTear = Isaac.Spawn( 2, TearVariant, 0, ShooterEntity.Position, v, ShooterEntity ) -- 2 = EntityType Tear
	local Sprite = customTear:GetSprite()
	customTear.CollisionDamage = customTear.CollisionDamage * DmgMult
	Sprite:Play( Sprite:GetDefaultAnimation() , true )
	return customTear
end

function PlayFamiliarShootAnimation( playerDir, Familiar )  -- Custom Familiar Shoot Animation Function
	local s = Familiar:GetSprite()
	local f = s:GetFrame()
	local framz_ = 14
	local framz_a = framz_ * 0.3
	s.PlaybackSpeed = 0.63

	if playerDir == 0 then -- left
		s.FlipX = true
		if not s:IsPlaying("FloatSide") and f >= framz_a then
			s:Play("FloatSide", true)
		elseif not s:IsPlaying("FloatShootSide") and f >= framz_ then
			s:Play("FloatShootSide", true)
		end
		s:Update()
	elseif playerDir == 1 then --up
		if not s:IsPlaying("FloatUp") and f >= framz_a then
			s:Play("FloatUp", true)
		elseif not s:IsPlaying("FloatShootUp") and f >= framz_ then
			s:Play("FloatShootUp", true)
		end
		s:Update()
	elseif playerDir == 2 then -- right
		s.FlipX = false
		if not s:IsPlaying("FloatSide") and f >= framz_a then
			s:Play("FloatSide", true)
		elseif not s:IsPlaying("FloatShootSide") and f >= framz_ then
			s:Play("FloatShootSide", true)
		end
		s:Update()
	elseif playerDir == 3 then --down
		if not s:IsPlaying("FloatDown") and f >= framz_a then
			s:Play("FloatDown", true)
		elseif not s:IsPlaying("FloatShootDown") and f >= framz_ then
			s:Play("FloatShootDown", true)
		end
		s:Update()
	else
		if not s:IsPlaying("FloatDown") and f >= framz_ then
			s:Play("FloatDown", true)
		end
	end
end

function hasTransfo(pool, trigger) -- check if the player transforms with items from pool. Triggers at trigger items
	local cnt = 0
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Items.ottid_i) then
		trigger = trigger - 1
	end
	for i=1, #pool do
		for j=1, #PICKED_ACTIVE_COLLECTIBLES do
			if pool[i] == PICKED_ACTIVE_COLLECTIBLES[j] then
				cnt = cnt + 1
			end
		end
		for j=1, #PICKED_PASSIVE_COLLECTIBLES do
			if pool[i] == PICKED_PASSIVE_COLLECTIBLES[j] then
				cnt = cnt + 1
			end
		end
	end
	if cnt >= trigger then
		return true
	else
		return false
	end
end

function getGrid() -- get all grid entities in the current room, returns a table with all grid entities from left to right, up to dwn
	local room = Game():GetRoom()
	local size = room:GetGridSize()-1
	local grid = {}
	for i=1, size do
		if room:GetGridEntity(i) == nil then
			table.insert(grid, false)
		else
			table.insert(grid, room:GetGridEntity(i))
		end
	end
	return grid
end

function getGridIndex(direction, base_index, distance) --direction from Direction enum && return the index based on base_index
	distance = distance or 1
	local index = 0
	local room = Game():GetRoom()
	if direction == Direction.LEFT then
		index = -1 * distance
	elseif direction == Direction.RIGHT then
		index = 1 * distance
	elseif direction == Direction.UP then
		index = -room:GetGridWidth() * distance
	elseif direction == Direction.DOWN then
		index = room:GetGridWidth() * distance
	else
		index = 0
	end
	return base_index + index
end

function BounceHearts(heart)
	local player = Isaac.GetPlayer(0)
	local velocity = player.Velocity
	heart.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	if getDistance(player.Position, heart.Position) <= 16 then
		heart:AddVelocity(velocity)
	end
	--BounceHeartHeart(heart)
end

function BounceHeartHeart(heart1)
	local entities = Isaac.GetRoomEntities()
	for j=1, #entities do
		local e2 = entities[j]
		if e2.Type == 5 and e2.Variant == 10 then
			local velocity = heart1.Velocity
			if getDistance(heart1.Position, e2.Position) <= 20 then
				e2:AddVelocity(velocity)
				heart1.Velocity = Vector(0,0)
			end
		end
	end
end

function playerHasFullHealth()
	local player = Isaac.GetPlayer(0)
	local max_hearts = 24
	if player:HasCollectible(Items.solomon_i) then max_hearts = 12 end
	local bitmask = {true, true, true} -- 1:player has max redhearts and soulhearts if true 2:player has max blackhearts if true 3:player has red heart damage
	local soul = player:GetSoulHearts()
	local red = player:GetMaxHearts()
	if red+soul < max_hearts then bitmask[1] = false else bitmask[1] = true end
	if IsFullBlackHearts2(player) then bitmask[2] = true else bitmask[2] = false end
	if player:GetHearts()<red then bitmask[3] = false else bitmask[3] = true end
	return bitmask
end

function boolToInt(bool) --cast a boolean to an integer
	if bool then
		return 1
	else
		return 0
	end
end

function has_value (tab, val) -- checks if tab has val inside it
  for index, value in ipairs (tab) do
    if value == val then
      return true
    end
  end
  return false
end

function GetRoomCenter()
    local room = Game():GetRoom()
    local roomshape = room:GetRoomShape()
    local center =room:GetCenterPos()
	local roomcenter = nil
	
    if not room:IsLShapedRoom() then
        roomcenter = Vector( center.X, center.Y )
    elseif roomshape == 9 then
        roomcenter = Vector( center.X + 260, center.Y + 140 )
    elseif roomshape == 10 then
        roomcenter = Vector( center.X - 260, center.Y + 140 )
    elseif roomshape == 11 then
        roomcenter = Vector( center.X + 260, center.Y - 140 )
    elseif roomshape == 12 then
        roomcenter = Vector( center.X - 260, center.Y - 140 )
    end
    return roomcenter
end

function print(...)
	local str, sep = "", ""
	for i=1, select('#', ...) do
		str = str .. sep .. tostring(select(i, ...))
		sep = '\t'
	end
	--return Isaac.ConsoleOutput(str)
	return Isaac.DebugString(str)
end

function getDistance(Vector1, Vector2)
	return math.abs((Vector1-Vector2):Length())
end

function isColinear(Vector1, Vector2, angle) --check si Vector1 et Vector2 sont colineaires à un angle près
	return (math.abs(Vector1:Normalized():Dot(Vector2:Normalized())) <= 1+angle and math.abs(Vector1:Normalized():Dot(Vector2:Normalized())) >= 1-angle)
end

function isRoomOver(room)
	return (room:GetAliveEnemiesCount() == 0 and room:GetAliveBossesCount() == 0 and room:IsClear())
end

function GetNumberOfDmgUps(player)
	local base_damage = 3.5
	local flat_dmg = 0
	if player:GetPlayerType() == PlayerType.PLAYER_EVE then
		base_damage = base_damage * 0.75
	elseif player:GetPlayerType() == PlayerType.PLAYER_XXX then
		base_damage = base_damage * 1.05
	elseif player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_CAIN or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2 then
		base_damage = base_damage * 1.2
	elseif player:GetPlayerType() == PlayerType.PLAYER_JUDAS then
		base_damage = base_damage * 1.35
	elseif player:GetPlayerType() == PlayerType.PLAYER_AZAZEL then
		base_damage = base_damage * 1.5
	elseif player:GetPlayerType() == PlayerType.PLAYER_BLACKJUDAS then
		base_damage = base_damage * 2
	end
	if player:HasCollectible(149) then
		flat_dmg = flat_dmg + 40
	end
	if player:HasTrinket(35) then
		flat_dmg = flat_dmg + 2
	end
	local total_dmg_ups = ((((player.Damage - flat_dmg)/base_damage)^2)-1)/1.2
	return total_dmg_ups
end

function DamageToSet(player, damageup, damage_multiplier)
	local base_damage = 3.5
	local flat_dmg = 0
	if player:GetPlayerType() == PlayerType.PLAYER_EVE then
		base_damage = base_damage * 0.75
	elseif player:GetPlayerType() == PlayerType.PLAYER_XXX then
		base_damage = base_damage * 1.05
	elseif player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_CAIN or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2 then
		base_damage = base_damage * 1.2
	elseif player:GetPlayerType() == PlayerType.PLAYER_JUDAS then
		base_damage = base_damage * 1.35
	elseif player:GetPlayerType() == PlayerType.PLAYER_AZAZEL then
		base_damage = base_damage * 1.5
	elseif player:GetPlayerType() == PlayerType.PLAYER_BLACKJUDAS then
		base_damage = base_damage * 2
	end
	local mabite = base_damage*math.sqrt(GetNumberOfDmgUps(player)*1.2+1)
	flat_dmg = player.Damage - mabite
	return (base_damage*damage_multiplier*math.sqrt((GetNumberOfDmgUps(player)+damageup)*1.2+1))+flat_dmg
end

function GetClosestTear(entities, player, TType, TVariant)
    local e, tmp = nil, 0xFFFFFF
    local entities = Isaac.GetRoomEntities()
    for i=1, #entities do
        local bval =  entities[i].Position:Distance(player.Position)
        if entities[i].Parent and entities[i].Type == TType and entities[i].Variant ~= TVariant and entities[i].Parent.Type == 1 and bval < tmp then
            tmp = bval
            e = entities[i]
        end
    end
    return e
end

function explosionInRange(entity)
    local entities=Isaac.GetRoomEntities()
    local bombRange = 96.0 --96 : radius of a basic bomb
    if Isaac.GetPlayer(0):HasCollectible(106) then bombRange = 112 end --mr mega
    for i=1, #entities do
        if entities[i].Type == 1000 and entities[i].Variant == 1 then --effect bomb_explosion
            if getDistance(entities[i].Position, entity.Position) < bombRange then
                return true
            end
        end
    end
    return false
end

function IsEntityInPit(e)
	local ge = Game():GetRoom():GetGridEntityFromPos(e.Position)
	return ge and (ge.Desc.Type == 7) or false
end

function getAuthorizedIndexes(room)
	local shape = room:GetRoomShape()
	local authorized = {}
	local banned = {}
	local width = room:GetGridWidth()
	local height = room:GetGridHeight()
	
	if shape == RoomShape.ROOMSHAPE_LBR then
		for iw = width/2+1, width do
			for ih = height/2+1, height do
				table.insert(banned, iw+ih*width)
			end
		end
	elseif shape == RoomShape.ROOMSHAPE_LBL then
		for iw = 0, width/2-1 do
			for ih = height/2+1, height do
				table.insert(banned, iw+ih*width)
			end
		end
	elseif shape == RoomShape.ROOMSHAPE_LTL then
		for iw = 0, width/2-1 do
			for ih = 0, height/2-1 do
				table.insert(banned, iw+ih*width)
			end
		end
	elseif shape == RoomShape.ROOMSHAPE_LTR then
		for iw = width/2+1, width do
			for ih = 0, height/2-1 do
				table.insert(banned, iw+ih*width)
			end
		end
	end
	for i=1, room:GetGridSize() do
		if not has_value(banned, i) then table.insert(authorized, i) end
	end
	return authorized
end

function IsGridEntityDestroyed(gridEntity)
	local types1 = {2, 3, 4, 5, 6, 11, 10, 22, 21}
	local types2 = {14, 12}
	if has_value(types1, gridEntity.Desc.Type) then
		return gridEntity.State == 2
	elseif has_value(types2, gridEntity.Desc.Type) then
		return gridEntity.State == 4
	else
		return false
	end
end

function isPositionInHitbox(position, hitbox, direction) -- position : player-entity hitbox : vec1 (bot left) vec2 (top right) (top)
    local vec1 = hitbox[1]
    local vec2 = hitbox[2]
    local checkX = false
    local checkY = false
    if direction == 2 or direction == 3 then
        if position.X >= vec1.X and position.X <= vec2.X then checkX=true end
    elseif direction == 0 then
        if position.X <= vec1.X and position.X >= vec2.X then checkX=true end
    elseif direction == 1 then
    	if position.X >= vec2.X and position.X <= vec1.X then checkX=true end
    end
    if direction == 2 or direction == 3 then
        if position.Y >= vec1.Y and position.Y <= vec2.Y then checkY=true end
    elseif direction == 0 then
        if position.Y <= vec2.Y and position.Y >= vec1.Y then checkY=true end
    elseif direction == 1 then
    	if position.Y <= vec1.Y and position.Y >= vec2.Y then checkY=true end
    end
    return (checkX and checkY)
end 
Minutes60fps = function(a) return a*60*60 end
Secondes60fps = function(a) return a*60 end
Minutes30fps = function(a) return a*60*30 end
Secondes30fps = function(a) return a*30 end
--no need to manually use SetRandomSeed(), it's already set by default in the code
SetRandomSeed = function () local r = math.random(time()) if g_vars.GlobalSeed ~= r then g_vars.GlobalSeed = r math.randomseed(g_vars.GlobalSeed) math.random();math.random();math.random(); end end

function isActiveCollectible(item_id)
    return has_value(ItemPools.ACTIVES, item_id)
end

function isPassiveCollectible(item_id)
    return has_value(ItemPools.PASSIVES, item_id)
end
--	###################################################################################
