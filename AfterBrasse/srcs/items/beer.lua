--[[
Item: "Beer" Type: "active item"
-Drazeb-
--]]

function AfterBrasse:use_beer()
	local p = Isaac.GetPlayer(0);
	local entities = Isaac.GetRoomEntities( )
	local game = Game()

	for i = 1, #entities do
		if entities[i]:IsVulnerableEnemy( ) then
			-- Ajout confusion et dmg aux ennemis --
			entities[i]:AddConfusion( EntityRef(p), 100, false )
			entities[i]:TakeDamage(10.0,0,EntityRef(p),1)
		end
	end

	-- Assombrissement la salle --
	game:Darken(1.0,100)
	return true
end
--Beer
AfterBrasse:AddCallback( ModCallbacks.MC_USE_ITEM, AfterBrasse.use_beer, Items.Beer_i );
