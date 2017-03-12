--[[
Trinket : Rusty Crowbar : permet de bomber le chest
-Dogeek-
epic fetus, doctor's remote et ipecac pas implémentés
range d'une bombe à déterminer précisément (là on a testé plusieurs ranges pour trouver une valeur correcte)
jouer l'animation des portes qui cassent et les maintenir cassées
--]]

local afterbrasse = RegisterMod("Afterbrasse", 1);
local rustyCrowbar = Isaac.GetTrinketIdByName("Rusty Crowbar");
local SLOTS = {DoorSlot.LEFT0, DoorSlot.UP0, DoorSlot.RIGHT0, DoorSlot.DOWN0, DoorSlot.LEFT1, DoorSlot.UP1, DoorSlot.RIGHT1, DoorSlot.DOWN1}


getnb = function(t) local o = 0 for i,k in pairs(t) do o = o + 1 end return o end

local function list_iter(t)
      local i = 0
      local n = #t
      return function ()
               i = i + 1
               if i <= n then return t[i] end
             end
    end

local function has_value (tab, val)
    for index, value in pairs (tab) do
        if value == val then
            return true
        end
    end
    return false
end

local iter_SLOTS = list_iter(SLOTS)

local function bombInFrontOfDoor(room, door)
    local lastBombTested = {}
    lastBombTested.Position = Vector(0xFFFFFF, 0xFFFFFF)
    local bombTested
    local entities = Isaac.GetRoomEntities()
    local distanceBombDoor = 0xFFFFFF
    for i=1, #entities do
        if entities[i].Type == EntityType.ENTITY_BOMBDROP and has_value(BombVariant, entities[i].Variant) then
            bombTested = entities[i]
            if (door.Position:__sub(bombTested.Position)):Length() <= door.Position:__sub(lastBombTested.Position):Length() then
                distanceBombDoor = math.min((door.Position - bombTested.Position):Length(), (door.Position - lastBombTested.Position):Length())
                lastBombTested = bombTested
            end
        end
    end
    if type(lastBombTested) == "userdata"  and 96.0 >= distanceBombDoor and lastBombTested:IsDead() then
        return true
    else
        return false
    end
end

function afterbrasse:rustyCrowbar_update()
    	local player = Isaac.GetPlayer(0)
    	--if player:HasTrinket(rustyCrowbar) then
		if Game():GetLevel():GetAbsoluteStage() == 11 then
			local currentRoom = Game():GetRoom()
			if currentRoom:IsInitialized() then
				for i=1, #SLOTS do
					local door = currentRoom:GetDoor(SLOTS[i])
					if currentRoom:IsDoorSlotAllowed(SLOTS[i]) and door ~= nil then
						if bombInFrontOfDoor(currentRoom, door) then
							door.Busted = true
							door:Open()
							local doorSprite = door.Sprite
							doorSprite:Play("Break", true);
							doorSprite:Play("BrokenOpen", true);
						end
					end
				end
			end
		end
    	--end
end


function afterbrasse:rendertext()
	local player = Isaac.GetPlayer(0)
	local debug_text = ""
	local currentRoom = Game():GetRoom()
	if currentRoom:IsInitialized() then
		debug_text = debug_text.."1 "
		for i=1, #SLOTS do -- in iter_SLOTS do
			debug_text = debug_text..tostring(SLOTS[i]).." "
			if currentRoom:IsDoorSlotAllowed(SLOTS[i]) and currentRoom:GetDoor(SLOTS[i]) ~= nil then
			--	debug_text = debug_text..tostring(i).." "
			--	debug_text = debug_text.."a "
			end
		end
	end
	Isaac.RenderText(debug_text, 50, 100, 255, 255, 255, 255)
end
afterbrasse:AddCallback(ModCallbacks.MC_POST_RENDER, afterbrasse.rendertext)

afterbrasse:AddCallback( ModCallbacks.MC_POST_UPDATE, afterbrasse.rustyCrowbar_update);
