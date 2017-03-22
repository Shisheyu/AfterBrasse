--[[
	by Krayz
--]]
--	##################################### SaveSysFunctions #################################
function IsNewGame() -- New run detection
	local game = Game()
	if game:GetFrameCount() == 0 and game:GetVictoryLap() == 0 then return true else return false end
end
function ResetSave() -- Reset saved data :: Not used anymore
	if Isaac.HasModData(_Stillbirth) then Isaac.RemoveModData(_Stillbirth) return true end return false
end
local function _save_(dataTable) -- Save Sys
	if dataTable then
		Isaac.SaveModData( _Stillbirth, json.encode(dataTable) )
		return true
	end
	return false
end
function _load_() -- Load Sys
	local dataTable = {}
	if Isaac.HasModData(_Stillbirth) then
		dataTable = json.decode(Isaac.LoadModData(_Stillbirth))
		return dataTable
	end
	return nil
end
local eVar = ""
local db = [[
					function _Stillbirth:rendertext()
						Isaac.RenderText(tostring(]]..eVar..[[), 200, 250, 255, 255, 10, 10)
					end
					_Stillbirth:AddCallback( ModCallbacks.MC_POST_RENDER, _Stillbirth.rendertext )
]]

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
-- K: SAVE related: You shall pass your way
-- TODO: Make a ForceSave() function [en cours]
-- TODO: ??? i can't remember u_u

local Sv_CollectibleSave = 0
local Sv_oldFrame = 0
local Sv_res_done = false
local Sv_Triggered_Items = false
local Sv_Triggered_Key = false
local Sv_Trigger_Force = false
local NOFSAVE = 0 -- can recycle as emergency stop?

local function data_init_save(base_data)
	for k,v in pairs(base_data) do
		if not k:find("PERMANENT_") then
			g_vars[k] = v
		end
	end
end
function ForceSave()
	NOFSAVE = NOFSAVE + 1
	if not Sv_Trigger_Force then
		Sv_Trigger_Force = true
		return Sv_Trigger_Force
	else
		return false
	end
end

function _Stillbirth:Mod_SaveMoreThanFramePerfect()
	if IsNewGame() and not Sv_res_done then
		data_init_save(initial_data_init())
		_save_(g_vars)
		Mod_SaveIt_Timer = 0
--~ 		NOFSAVE = 0
		Isaac.DebugString("NewGame Save reset")
		Sv_res_done = true
	end
	if ( Game():IsPaused() or Input.IsButtonTriggered(342, 0) or not Isaac.HasModData(_Stillbirth) ) and not Sv_Triggered_Key then
		NOFSAVE = NOFSAVE + 1
		Sv_Triggered_Key = true
		local p = Isaac.GetPlayer(0)
		db_c = _save_(g_vars)
		Sv_oldFrame = p.FrameCount
		Isaac.DebugString("Save by Sv_Triggered_Key/GamePaused")
	end
end
function _Stillbirth:Mod_SaveIt_Minutes()
	local p = Isaac.GetPlayer(0)
	local Mod_SaveIt_Timer = 0
	Mod_SaveIt_Timer = p.FrameCount  - Sv_oldFrame
	if Mod_SaveIt_Timer <= 0 then
		Sv_oldFrame = p.FrameCount
	end
	db_timer = Mod_SaveIt_Timer
	if p.FrameCount > 5 then
		if Sv_CollectibleSave ~= p:GetCollectibleCount() then
			Sv_Triggered_Items = true
			Sv_CollectibleSave = p:GetCollectibleCount()
			Sv_oldFrame = p.FrameCount
			Mod_SaveIt_Timer = p.FrameCount - Sv_oldFrame -- in case of active item switch so it doesn't register twice
		end
		if Sv_Triggered_Key and Mod_SaveIt_Timer >= Secondes30fps(10) then
			Sv_Triggered_Key = false
		end
		if Sv_Trigger_Force and Mod_SaveIt_Timer >= Secondes30fps(15) then
			Sv_Trigger_Force = false
		end
		if Mod_SaveIt_Timer >= Minutes30fps(5) or (Sv_Triggered_Items and Mod_SaveIt_Timer > 45) then
			if Sv_Triggered_Items then
				Isaac.DebugString("Save by Sv_Triggered_Items")
			else
				Isaac.DebugString("Save by Timer")
			end
			Sv_Triggered_Items = false
			db_c = _save_(g_vars)
			Sv_oldFrame = p.FrameCount
		end
	elseif p.FrameCount == 5 then
		Sv_res_done = false
	end
	dbz = p:IsVulnerableEnemy()
end
function _Stillbirth:Mod_SaveIt_Level(Curses) -- Save at Level start
	local level = Game():GetLevel()
--~ 	if g_vars.GlobalSeed == 0 then
--~ 		SetRandomSeed() -- Re-seed the random .. because why not.
--~ 		Isaac.DebugString("Seed Generated")
--~ 	end
	if level:GetAbsoluteStage() ~= 1 then
		db_c = _save_(g_vars)
		Isaac.DebugString("Save by Level")
--~ 		NOFSAVE = NOFSAVE + 1
		Mod_SaveIt_Timer = 0
		db_d = "SavedByLevel" .. "  " .. tostring(Curses)  .. " stage: " .. tostring(level:GetAbsoluteStage())
	end
	return Curses
end
_Stillbirth:AddCallback(ModCallbacks.MC_POST_UPDATE, _Stillbirth.Mod_SaveIt_Minutes);
_Stillbirth:AddCallback(ModCallbacks.MC_POST_RENDER, _Stillbirth.Mod_SaveMoreThanFramePerfect);
_Stillbirth:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, _Stillbirth.Mod_SaveIt_Level);
------------------------------------------------------------------------------------------------------------------------
