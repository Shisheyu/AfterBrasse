function _Stillbirth:BossCerberusUpdate(enemy)
	player = Isaac.GetPlayer(0);
	sprite = enemy:GetSprite();
	if(enemy.State == NpcState.STATE_INIT) then
		sprite:Play("Appear"); 
		enemy.State = NpcState.STATE_MOVE;
	end
	if(enemy.State == NpcState.STATE_MOVE) then
		sprite:Play("Walk");   
		randomAttack = math.random(1,60);
		if(randomAttack < 2) then
			enemy.State = NpcState.STATE_ATTACK;
			enemy.StateFrame = 0;
		end
		if(randomAttack > 2 and randomAttack < 5) then
			enemy.State = NpcState.STATE_ATTACK2;
			enemy.StateFrame = 0;
		end
	end
	if(enemy.State == NpcState.STATE_ATTACK) then
		if(enemy.StateFrame == 0) then
			sprite:Play("Rebirth");
			angle = math.random(1,180);
			mag = math.random(5,10);
			Isaac.Spawn(EntityType.ENTITY_SPIDER, 0, 0, enemy.Position, Vector.FromAngle(angle):__mul(mag), nil);
		end
		if(sprite:IsFinished("Rebirth")) then
			debugText = "is finished"
			enemy.State = NpcState.STATE_MOVE;
			enemy.StateFrame = 0;
		end
		enemy.StateFrame = enemy.StateFrame + 1;
	end
	if(enemy.State == NpcState.STATE_ATTACK2) then
		if(enemy.StateFrame == 0) then
			sprite:Play("Attack01")
		end
		if(enemy.StateFrame % 3 == 0) then
			angle = math.random(1,180)
			mag = math.random(5,10);
			Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, enemy.Position, Vector.FromAngle(angle):__mul(mag), nil)
		end
		if(sprite:IsFinished("Attack01")) then
			enemy.State = NpcState.STATE_MOVE
			enemy.StateFrame = 0
		end
		enemy.StateFrame = enemy.StateFrame + 1
	end
end

_Stillbirth:AddCallback(ModCallbacks.MC_NPC_UPDATE, _Stillbirth.BossCerberusUpdate, Enemies.boss_cerberus)
