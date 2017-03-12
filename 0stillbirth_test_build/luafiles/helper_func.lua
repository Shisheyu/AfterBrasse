
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

local function hasTransfo(pool, trigger) -- check if the player transforms with items from pool. Triggers at trigger items
	local cnt = 0
	local player = Isaac.GetPlayer(0)
	if trigger == nil
		local trigger = 3
	end
	if player:HasCollectible(oddit) then
		trigger = trigger - 1
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

local function getGrid() -- get all grid entities in the current room, returns a table with all grid entities from left to right, up to dwn
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

local function boolToInt(bool) --cast a boolean to an integer
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

Minutes60fps = function(a) return a*60*60 end
Secondes60fps = function(a) return a*60 end
Minutes30fps = function(a) return a*60*30 end
Secondes30fps = function(a) return a*30 end
--no need manually use SetRandomSeed(), it's already set by default in the code
SetRandomSeed = function () local r = math.random(time()) if g_vars.GlobalSeed ~= r then g_vars.GlobalSeed = r math.randomseed(g_vars.GlobalSeed) math.random();math.random();math.random(); end end

devilPoolPassive = {8, 51, 67, 79, 80, 81, 82, 113, 114, 118, 122, 134, 159, 163, 172, 187, 212, 215, 216, 225, 230, 237, 241, 259, 262, 268, 269, 275, 278, 311, 412, 408, 399, 391, 360, 409, 433, 431, 420, 417, 498, 462, 442, 468}

--	###################################################################################
