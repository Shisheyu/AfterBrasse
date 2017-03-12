
function _Stillbirth:rendertext()
	Isaac.RenderText("_load_a: " .. tostring(db_a), 100, 60, 255, 255, 255, 255)
	Isaac.RenderText("b: " .. tostring(db_b), 100, 70, 255, 255, 255, 255)
	Isaac.RenderText("c_save_: " .. tostring(db_c), 100, 80, 255, 255, 255, 255)
	Isaac.RenderText("d: " .. tostring(db_d), 100, 90, 255, 255, 255, 255)
	Isaac.RenderText("Mod_SaveIt_timer: " .. tostring(db_timer) .. "/" .. tostring(Minutes30fps(5)) , 100, 100, 255, 255, 255, 255)
	Isaac.RenderText("Reset_e: " .. tostring(db_e), 100, 110, 255, 255, 255, 255)
	Isaac.RenderText("IsNewGame(): " .. tostring(IsNewGame()), 100, 120, 255, 255, 255, 255)
	Isaac.RenderText("dbz: " .. tostring(dbz), 100, 130, 255, 255, 255, 255)
	Isaac.RenderText("NumOfSave: " .. tostring(NOFSAVE), 100, 140, 255, 255, 255, 255)
	Isaac.RenderText("blindPact_pickedItem: " .. tostring(g_vars.blindPact_pickedItem), 100, 150, 255, 255, 255, 255)
	Isaac.RenderText("blindPact_previousItem: " .. tostring(g_vars.blindPact_previousItem), 100, 160, 255, 255, 255, 255)
	Isaac.RenderText("GlobalSeed: " .. tostring(g_vars.GlobalSeed), 100, 170, 255, 255, 255, 255)
	Isaac.RenderText("db_z: " .. tostring(db_z), 100, 180, 255, 255, 255, 255)
end
_Stillbirth:AddCallback( ModCallbacks.MC_POST_RENDER, _Stillbirth.rendertext )

--[[
db_a = nil
function _Stillbirth:rendertext()
	Isaac.RenderText(": " .. tostring(db_a), 100, 60, 255, 255, 255, 255)
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_RENDER, _Stillbirth.rendertext)
--]]
