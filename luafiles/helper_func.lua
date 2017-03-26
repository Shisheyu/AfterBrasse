
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

local bossPool = {15, 346, 438, 254, 342, 198, 25, 340, 165, 354, 24, 23, 240, 70, 343, 100, 22, 194, 12, 193, 253, 344, 195, 30, 31, 355, 29, 370, 219, 428, 141, 51, 218, 183, 341, 32, 27, 14, 26, 339, 255, 143, 196, 176, 92, 345, 28, 101, 92, 458, 455, 456, 454}
local itemPool = {191, 245, 359, 15, 74, 320, 188, 491, 493, 465, 214, 161, 222, 443, 300, 308, 272, 506, 231, 274, 391, 473, 279, 7, 509, 157, 273, 140, 125, 131, 353, 19, 129, 8, 144, 385, 209, 377, 319, 497, 301, 307, 162, 62, 154, 69, 453, 457, 466, 369, 224, 4, 48, 371, 316, 170, 278, 117, 373, 336, 446, 237, 113, 469, 57, 445, 52, 265, 236, 381, 168, 368, 496, 310, 410, 240, 401, 404, 361, 467, 257, 128, 364, 418, 405, 318, 163, 495, 225, 432, 460, 210, 398, 206, 10, 167, 269, 374, 313, 178, 375, 256, 470, 242, 234, 148, 149, 201, 276, 494, 311, 266, 388, 440, 502, 332, 444, 270, 302, 304, 362, 384, 435, 471, 275, 277, 447, 96, 88, 99, 100, 87, 213, 365, 46, 411, 312, 12, 53, 394, 449, 202, 436, 71, 173, 110, 200, 55, 114, 228, 508, 217, 109, 322, 229, 106, 431, 153, 5, 317, 271, 378, 6, 426, 121, 120, 115, 75, 430, 461, 227, 309, 169, 261, 281, 379, 407, 223, 190, 174, 267, 95, 14, 72, 268, 221, 389, 189, 94, 172, 220, 306, 321, 142, 366, 305, 390, 393, 448, 459, 280, 67, 264, 330, 143, 91, 89, 211, 3, 176, 367, 138, 315, 463, 92, 299, 395, 244, 152, 68, 180, 334, 103, 101, 2, 329, 333, 151, 104, 155, 98, 1, 335, 13, 108, 358, 314, 233, 150, 350, 397, 452, 303, 76, 492, 392, 65, 136, 286, 186, 42, 78, 287, 58, 288, 504, 294, 482, 160, 437, 406, 489, 175, 481, 124, 85, 47, 291, 127, 485, 158, 283, 285, 386, 476, 166, 284, 39, 41, 123, 86, 37, 77, 147, 478, 146, 137, 292, 325, 507, 49, 382, 352, 422, 282, 323, 40, 421, 56, 295, 351, 488, 427, 102, 171, 192, 44, 419, 111, 97, 105, 93, 66, 107, 36, 324, 298, 484, 45} --actives après le 65 (inclus)
--	###################################################################################