--	##################################### Local Functions  ####################################

function IsShooting(player) -- return if player is shooting(true) or not(false)
	if player:GetFireDirection() ~= -1 then
		return true
	else
		return false
	end
end

function IsFullBlackHearts(player)  -- Usefull use of GetBlackHeart()
	return (function(n) local s = player:GetSoulHearts() for i=0, 12 do if (1<<i)-1 == n then return ((i*2)==s and true) or false end end return false end)( player:GetBlackHearts() )
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
		for j=1, #g_vars.PICKED_ACTIVE_COLLECTIBLES do
			if pool[i] == g_vars.PICKED_ACTIVE_COLLECTIBLES then
				cnt = cnt + 1
			end
		end
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

function getGridIndex(direction, base_index) --direction from Direction enum && return the index based on the player
	local index = 0
	local room = Game():GetRoom()
	if direction == Direction.LEFT then
		index = -1
	elseif direction == Direction.RIGHT then
		index = 1
	elseif direction == Direction.UP then
		index = -room:GetGridWidth()
	elseif direction == Direction.DOWN then
		index = room:GetGridWidth()
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
	local bitmask = {true, true} -- 1:player has max redhearts and soulhearts if true 2:player has max blackhearts if true
	local soul = player:GetSoulHearts()
	local red = player:GetMaxHearts()
	if red+soul < max_hearts then bitmask[1] = false else bitmask[1] = true end
	if IsFullBlackHearts(player) then bitmask[2] = true else bitmask[2] = false end
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
	return Isaac.DebugString(str)
end

function getDistance(Vector1, Vector2)
	return math.abs((Vector1-Vector2):Length())
end

function isColinear(Vector1, Vector2, angle) --check si Vector1 et Vector2 sont colineaires à un angle près
	if math.abs(Vector1:Normalized():Dot(Vector2:Normalized())) <= 1+angle and math.abs(Vector1:Normalized():Dot(Vector2:Normalized())) >= 1-angle then
		return true
	else
		return false
	end
end

function isRoomOver(room)
	if room:GetAliveEnemiesCount() == 0 and room:GetAliveBossesCount() == 0 and room:IsClear() then
		return true
	else
		return false
	end
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
	return base_damage*damage_multiplier*math.sqrt((GetNumberOfDmgUps(player)+damageup)*1.2+1)+flat_dmg
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

Minutes60fps = function(a) return a*60*60 end
Secondes60fps = function(a) return a*60 end
Minutes30fps = function(a) return a*60*30 end
Secondes30fps = function(a) return a*30 end
--no need to manually use SetRandomSeed(), it's already set by default in the code
SetRandomSeed = function () local r = math.random(time()) if g_vars.GlobalSeed ~= r then g_vars.GlobalSeed = r math.randomseed(g_vars.GlobalSeed) math.random();math.random();math.random(); end end

devilPoolPassive = {8, 51, 67, 79, 80, 81, 82, 113, 114, 118, 122, 134, 159, 163, 172, 187, 212, 215, 216, 225, 230, 237, 241, 259, 262, 268, 269, 275, 278, 311, 412, 408, 399, 391, 360, 409, 433, 431, 420, 417, 498, 462, 442, 468}
libraryPool = {33, 34, 35, 58, 65, 78, 97, 192, 282, 287, 292}
guppyPool = {145, 133, 81, 212, 134, 187}
beezlebubPool = {320, 272, 274, 279, 57, 128, 10, 248, 9, 264, 151, 148, 364, 365, 430, 426}
funGuyPool = {398, 71, 12, 120, 121, 11, 342}
seraphimPool = {33 , 185, 112, 184, 313, 173, 72 , 363, 101}
bobPool = {273, 42,  140, 149}
spunPool = {493, 496, 240, 70, 14, 143, 13, 345}
momPool = {102, 39, 41, 217, 55, 139, 110, 114, 30, 200, 228, 199, 31, 29, 195, 355, 508, 547}
conjoinedPool = {8, 167, 169, 100, 322, 268, 67}
leviathanPool = {83, 79, 262, 80, 51, 159, 399 , 230, 118}
poopPool = {36 ,291, 236}
bookWormPool = {35, 65, 78, 34, 33, 97, 287, 58, 282, 292, 192, 531}
spiderBabyPool = {288, 153, 211, 89, 171, 403, 556}

ItemPools = {}

ItemPools.POOL_BOSS = {15, 346, 438, 254, 342, 198, 25, 340, 165, 354, 24, 23, 240, 70, 343, 100, 22, 194, 12, 193, 253, 344, 195, 30, 31, 355, 29, 370, 219, 428, 141, 51, 218, 183, 341, 32, 27, 14, 26, 339, 255, 143, 196, 176, 92, 345, 28, 101, 92, 458, 455, 456, 454}
ItemPools.POOL_TREASURE = {191, 245, 359, 15, 74, 320, 188, 491, 493, 465, 214, 161, 222, 443, 300, 308, 272, 506, 231, 274, 391, 473, 279, 7, 509, 157, 273, 140, 125, 131, 353, 19, 129, 8, 144, 385, 209, 377, 319, 497, 301, 307, 162, 62, 154, 69, 453, 457, 466, 369, 224, 4, 48, 371, 316, 170, 278, 117, 373, 336, 446, 237, 113, 469, 57, 445, 52, 265, 236, 381, 168, 368, 496, 310, 410, 240, 401, 404, 361, 467, 257, 128, 364, 418, 405, 318, 163, 495, 225, 432, 460, 210, 398, 206, 10, 167, 269, 374, 313, 178, 375, 256, 470, 242, 234, 148, 149, 201, 276, 494, 311, 266, 388, 440, 502, 332, 444, 270, 302, 304, 362, 384, 435, 471, 275, 277, 447, 96, 88, 99, 100, 87, 213, 365, 46, 411, 312, 12, 53, 394, 449, 202, 436, 71, 173, 110, 200, 55, 114, 228, 508, 217, 109, 322, 229, 106, 431, 153, 5, 317, 271, 378, 6, 426, 121, 120, 115, 75, 430, 461, 227, 309, 169, 261, 281, 379, 407, 223, 190, 174, 267, 95, 14, 72, 268, 221, 389, 189, 94, 172, 220, 306, 321, 142, 366, 305, 390, 393, 448, 459, 280, 67, 264, 330, 143, 91, 89, 211, 3, 176, 367, 138, 315, 463, 92, 299, 395, 244, 152, 68, 180, 334, 103, 101, 2, 329, 333, 151, 104, 155, 98, 1, 335, 13, 108, 358, 314, 233, 150, 350, 397, 452, 303, 76, 492, 392, 65, 136, 286, 186, 42, 78, 287, 58, 288, 504, 294, 482, 160, 437, 406, 489, 175, 481, 124, 85, 47, 291, 127, 485, 158, 283, 285, 386, 476, 166, 284, 39, 41, 123, 86, 37, 77, 147, 478, 146, 137, 292, 325, 507, 49, 382, 352, 422, 282, 323, 40, 421, 56, 295, 351, 488, 427, 102, 171, 192, 44, 419, 111, 97, 105, 93, 66, 107, 36, 324, 298, 484, 45} --actives après le 65 (inclus)
ItemPools.POOL_DEVIL = {8, 34, 35, 51, 67, 79, 80, 81, 82, 83, 84, 97, 113, 114, 118, 122, 126, 133, 134, 145, 159, 163, 172, 187, 212, 215, 216, 225, 230, 237, 241, 259, 262, 269, 268, 275, 278, 292, 311, 412, 408, 399, 391, 360, 409, 433, 431, 420, 417, 441, 498, 477, 475, 462, 442, 468} 
ItemPools.POOL_ANGEL = {33, 72, 98, 101, 108, 112, 124, 142, 146, 156, 162, 173, 178, 182, 184, 185, 243, 313, 326, 331, 332, 333, 334, 335, 415, 413, 400, 390, 374, 363, 423, 387, 499, 498, 490, 464, 477, 510} 
ItemPools.POOL_SECRET = {321, 316, 286, 287, 271, 262, 242, 226, 213, 190, 131, 127, 106, 94, 84, 74, 35, 20, 17, 16, 11, 120, 121, 258, 405, 388, 389, 501, 480, 450} 
ItemPools.POOL_LIBRARY = {33, 34, 35, 58, 65, 78, 97, 192, 282, 287, 292} 
ItemPools.POOL_CHALLENGE = {209, 220, 140, 131, 125, 137, 106, 37, 19, 483} 
ItemPools.POOL_GOLDENCHEST = {4, 38, 42, 145, 188, 179, 215, 242, 273, 361, 50, 429, 500, 94, 252, 271, 389, 131, 119, 135} 
ItemPools.POOL_REDCHEST = {297, 212, 145, 134, 133, 81, 371, 316, 140, 475} 
ItemPools.POOL_BEGGAR = {22, 23, 24, 26, 25, 46, 54, 21, 102, 111, 177, 180, 195, 198, 204, 246, 271, 294, 385, 376, 362, 144, 485, 455, 456, 447} 
ItemPools.POOL_DEMONBEGGAR = {262, 241, 240, 225, 216, 195, 143, 102, 14, 13, 70, 340, 345, 113, 417, 503, 496, 491, 487, 475} 
ItemPools.POOL_CURSE = {51, 79, 80, 81, 133, 134, 145, 212, 215, 216, 225, 241, 260, 408, 371, 508, 503, 496, 475, 468, 451, 442} 
ItemPools.POOL_KEYBEGGAR = {10, 128, 264, 57, 272, 199, 175, 320, 364, 365, 388} 
ItemPools.POOL_BOSSRUSH = {209, 220, 140, 131, 125, 137, 106, 37, 19, 401, 378, 371, 367, 366, 353, 432} 
ItemPools.POOL_DUNGEON = {22, 23, 24, 25, 26, 29, 30, 31, 39, 41, 55, 102, 110, 114, 139, 195, 198, 199, 200, 217, 228, 355, 346, 508, 439, 456} 
ItemPools.POOL_GREED_TREASURE = {1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 48, 50, 52, 55, 57, 62, 67, 68, 69, 87, 88, 89, 94, 95, 96, 98, 99, 100, 101, 103, 104, 106, 108, 110, 111, 114, 115, 117, 120, 120, 125, 128, 131, 132, 138, 140, 142, 148, 149, 150, 151, 152, 153, 154, 155, 157, 161, 162, 163, 167, 168, 169, 170, 172, 174, 188, 189, 190, 191, 200, 201, 206, 209, 210, 213, 214, 217, 220, 221, 222, 223, 224, 226, 228, 229, 231, 233, 234, 236, 237, 242, 244, 245, 254, 256, 257, 258, 261, 264, 265, 266, 267, 268, 269, 271, 273, 274, 277, 279, 280, 281, 299, 300, 301, 302, 303, 305, 306, 307, 308, 309, 310, 311, 312, 315, 316, 317, 318, 319, 320, 321, 322, 329, 330, 331, 332, 333, 334, 335, 336, 353, 358, 359, 362, 364, 365, 366, 367, 368, 369, 371, 373, 374, 375, 377, 378, 379, 380, 384, 389, 391, 392, 393, 394, 395, 397, 398, 401, 407, 410, 411, 13, 35, 34, 37, 38, 42, 45, 47, 56, 64, 65, 77, 78, 85, 93, 97, 102, 107, 120, 124, 137, 146, 175, 186, 192, 288, 291, 325, 349, 351, 352, 357, 382, 383, 73, 440, 436, 434, 432, 431, 430, 426, 425, 421, 416, 509, 508, 507, 506, 504, 503, 502, 497, 496, 495, 494, 493, 484, 473, 471, 470, 469, 467, 466, 465, 463, 461, 459, 460, 457, 453, 452, 450, 449, 448, 447, 446, 445, 444, 443} 
ItemPools.POOL_GREED_BOSS = {11, 14, 15, 16, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 71, 70, 73, 101, 120, 120, 132, 143, 176, 183, 193, 194, 195, 196, 197, 198, 199, 240, 253, 254, 255, 314, 339, 340, 341, 342, 343, 344, 345, 346, 355, 354, 370, 438, 428, 458, 456, 455, 454} 
ItemPools.POOL_GREED_SHOP = {402, 380, 372, 356, 348, 297, 289, 286, 285, 284, 283, 386, 406, 260, 247, 246, 248, 208, 204, 166, 156, 116, 105, 91, 84, 76, 75, 63, 46, 139, 403, 405, 73, 252, 251, 434, 416, 439, 505, 500, 489, 488, 487, 486, 485, 483, 482, 481, 478, 477, 476, 475, 472, 451} 
ItemPools.POOL_GREED_CURSE = {133, 134, 145, 212, 81, 73} 
ItemPools.POOL_GREED_DEVIL = {412, 409, 408, 399, 391, 360, 311, 292, 269, 270, 268, 259, 241, 237, 225, 216, 212, 187, 172, 159, 145, 134, 133, 132, 122, 117, 114, 115, 113, 97, 83, 82, 81, 80, 79, 73, 67, 51, 34, 35, 230, 433, 431, 420, 441, 503, 462, 451, 442, 468} 
ItemPools.POOL_GREED_ANGEL = {415, 413, 407, 400, 390, 387, 363, 335, 334, 333, 331, 313, 243, 197, 178, 182, 184, 185, 173, 162, 138, 112, 78, 73, 72, 7, 423, 499, 490, 464} 
ItemPools.POOL_GREED_LIBRARY = {34, 35, 58, 65, 78, 97, 123, 192, 262, 287, 292} 
ItemPools.POOL_GREED_SECRET = {73} 
ItemPools.POOL_GREED_GOLDENCHEST = {4, 38, 42, 145, 188, 179, 242, 273, 361, 50} 
ItemPools.POOL_BOMBBEGGAR = {19, 37, 125, 131, 140, 190, 209, 220, 250, 256, 353, 366, 367, 483}
ItemPools.ACTIVES = {33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 47, 49, 56, 58, 65, 66, 77, 78, 81, 83, 84, 85, 86, 93, 97, 102, 105, 107, 111, 123, 124, 126, 127, 130, 133, 135, 136, 137, 145, 146, 147, 158, 160, 164, 166, 171, 175, 177, 181, 186, 192, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 323, 324, 325, 326, 338, 347, 348, 349, 351, 352, 357, 362, 382, 383, 386, 396, 406, 419, 421, 422, 427, 439, 441, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 504, 507, 510}
ItemPools.PASSIVES = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 46, 48, 50, 51, 52, 53, 54, 55, 57, 60, 62, 63, 64, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 79, 80, 82, 87, 88, 89, 90, 91, 92, 94, 95, 96, 98, 99, 100, 101, 103, 104, 106, 108, 109, 110, 112, 113, 114, 115, 116, 117, 118, 119, 121, 122, 125, 128, 129, 131, 132, 134, 138, 139, 140, 141, 142, 143, 144, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 159, 161, 162, 163, 165, 167, 168, 169, 170, 171, 172, 173, 174, 176, 178, 179, 180, 182, 183, 184, 185, 187, 188, 189, 190, 191, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 339, 340, 341, 342, 343, 344, 345, 346, 350, 353, 354, 355, 356, 358, 359, 360, 361, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381, 384, 385, 387, 388, 389, 390, 391, 392, 393, 394, 395, 397, 398, 399, 400, 401, 402, 403, 404, 405, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 420, 423, 424, 425, 426, 428, 429, 430, 431, 432, 433, 440, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 456, 461, 462, 463, 464, 466, 467, 468, 469, 470, 471, 472, 473, 474, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 505, 506, 508, 509}

SLOTS = {DoorSlot.LEFT0, DoorSlot.UP0, DoorSlot.RIGHT0, DoorSlot.DOWN0, DoorSlot.LEFT1, DoorSlot.UP1, DoorSlot.RIGHT1, DoorSlot.DOWN1}

function isActiveCollectible(item_id)
    if has_value(ItemPools.ACTIVES, item_id) then
        return true
    else
        return false
    end
end

function isPassiveCollectible(item_id)
    if has_value(ItemPools.PASSIVES, item_id) then
        return true
    else
        return false
    end
end
--	###################################################################################
