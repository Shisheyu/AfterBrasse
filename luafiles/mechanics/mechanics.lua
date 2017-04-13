require("luafiles/mechanics/curses")
require("luafiles/mechanics/pills")
require("luafiles/mechanics/transformations")
require("luafiles/mechanics/character_init")
--require("luafiles/mechanics/devil_boss")
--require("luafiles/mechanics/cards")

local everyActiveItems = {33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 47, 49, 56, 58, 65, 66, 77, 78, 83, 84, 85, 86, 93, 97, 102, 105, 107, 111, 122, 123, 124, 126, 127, 130, 133, 135, 136, 137, 145, 146, 147, 158, 160, 164, 166, 171, 175, 177, 181, 186, 192, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 323, 324, 325, 326, 338, 347, 348, 349, 351, 352, 357, 382, 383, 386, 396, 406, 415, 419, 421, 422, 425, 427, 434, 437, 439, 441, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 504, 507, 510, 512, 515, 516, Items.D_glasses_i, Items.blankTissues_i, Items.babyBlender_i, Items.cricketsPaw_i, Items.Beer_i} --to update && improve

function _Stillbirth:TrackItems()
	local player = Isaac.GetPlayer(0)
	local TotalItems = 520 + 500
	if player:GetCollectibleCount() >= g_vars.TRACK_COLLECTIBLES then
		g_vars.TRACK_COLLECTIBLES = player:GetCollectibleCount()
		for i=1, TotalItems do
			if player:HasCollectible(i) then --and not has_value(g_vars.PICKED_PASSIVE_COLLECTIBLES, i) and not has_value(g_vars.PICKED_ACTIVE_COLLECTIBLES, i) then
				if isActiveCollectible(i) then
					print("active")
				--	table.insert(g_vars.PICKED_ACTIVE_COLLECTIBLES, i)
				else
					print("passive")
				--	table.insert(g_vars.PICKED_PASSIVE_COLLECTIBLES, i)
				end
			end
		end
	end
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, _Stillbirth.TrackItems) -- error here
