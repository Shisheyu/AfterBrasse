--[[
Stillbirth
"100% IMPOSSIBLE TO CODE" -dogeek
--]]
_Stillbirth = RegisterMod("Stillbirth", 1)

--/!\ actually, dosen't work with --luadebug /!\
-- "--luadebug" check
local function requireCheck()
  require("luafiles/requirecheck.lua")
end
local ok, err = pcall(requireCheck)
Isaac.DebugString(tostring(ok))
if not ok then
	Isaac.DebugString(err)
	function _Stillbirth:FatalError()
		Isaac.RenderText("MOD LOADING FAILED:", 5, 213, 255, 0, 0, 255)
		Isaac.RenderText("IF YOU HAVE --luadebug ACTIVE, PLEASE DESACTIVE IT", 5, 225, 255, 0, 0, 255)
		Isaac.RenderText("IF YOU DO NOT HAVE --luadebug ACTIVE,", 5, 238, 255, 0, 0, 255)
		Isaac.RenderText("PLEASE REPORT THE BUG(please add your log.txt)", 5, 250, 255, 0, 0, 255)
	end
	_Stillbirth:AddCallback( ModCallbacks.MC_POST_RENDER, _Stillbirth.FatalError )
else
	math = require("math")
	string = require("string")
	table = require("table")
	time = Isaac.GetTime
	table._getn = function(t) local n = 0 if type(t) ~= type({}) then return -1 end for k,v in pairs(t) do n = n + 1 end return n end

	require("luafiles/helper_func.lua")

	Items =	{
							moneyLuck_i = Isaac.GetItemIdByName( "Money = Luck" ),
							Beer_i = Isaac.GetItemIdByName( "Dad's Beer" ),
							brave_shoe_i = Isaac.GetItemIdByName( "Brave Shoe" ),
							tech0_i = Isaac.GetItemIdByName("Technology 0"),
							hot_pizza_slice_i = Isaac.GetItemIdByName("Hot Pizza Slice"),
							golden_idol_i = Isaac.GetItemIdByName("Golden Idol"),
							medusa_head_i = Isaac.GetItemIdByName("Medusa's Head"),
							blind_Pact_i = Isaac.GetItemIdByName("Blind Pact"),
							cricketsPaw_i = Isaac.GetItemIdByName("Cricket's Paw"),
							solomon_i = Isaac.GetItemIdByName("salomon"),
							cataracte_i = Isaac.GetItemIdByName("cataracte"),
							BubblesHead_i = Isaac.GetItemIdByName( "Bubble's Head" ),
							SunWukong_i = Isaac.GetItemIdByName("SunWukong"),
							FAM_BombBum_i = Isaac.GetItemIdByName("fam_BombBum_I"),
							first_blood_i = Isaac.GetItemIdByName("First Blood"),
							choranaptyxic_i = Isaac.GetItemIdByName("Choranaptyxic"),
							blankTissues_i = Isaac.GetItemIdByName("Blank Tissues"),
							electron_i = Isaac.GetItemIdByName("Electron"),
							magic_mirror_i = Isaac.GetItemIdByName("Magic Mirror"),
							encyclopedia_i = Isaac.GetItemIdByName("Encyclopedia"),
							ExBanana_i = Isaac.GetItemIdByName( "Explosive Banana" ),
							--mizaru_i = Isaac.GetItemIdByName("Mizaru")
							oddit_i = 1 -- TEMPORARY PLACEHOLDER FOR ODDIT
						}

	Familiars =	{
							SunWukong_Familiar_Variant = Isaac.GetEntityVariantByName("SunWukong"),
							FAM_BombBumFamiliar = Isaac.GetEntityTypeByName("fam_BombBum"),
							FAM_BombBumFamiliarVariant = Isaac.GetEntityVariantByName("fam_BombBum"),
							electronFamiliar = Isaac.GetEntityTypeByName("fam_electron"),
							electronFamiliarVariant = Isaac.GetEntityVariantByName("fam_electron")

						}

	CustomEntities =	{
									TearLeaf_Variant = Isaac.GetEntityVariantByName( "Tear leaf" ),
									BananaEntity = Isaac.GetEntityTypeByName( "Explosive Banana" )
								}
	Trinkets = {
							chainmail_t = Isaac.GetTrinketIdByName("Chainmail"),
							greenCross_t = Isaac.GetTrinketIdByName("Green Cross"),
							kramp_tooth_t = Isaac.GetTrinketIdByName("Krampus's Tooth")

	}

	--[[
					/!\	EXEMPLES OF VARIABLES WHO CAN BE SAVED WITH THE ACTUAL SYSTEM:
							Variables Only start with a letter.
							If you have a NIL value it Will and May be turn to FALSE automatically to properly save
							(as long as condition are not in the form "if variable ~= nil" but "not nil", "not nil" and "not false" behaving the same way, it may not introduce bugs)
								g_vars =	{
									foo =1,
									foo2= 2,
									bar_=3,
									bar1_1 = 4,
									NEG_Fus1=-9,
									False_Ro_2= false,
									True_Dah_3= true,
									Tou_tan__kha___mon____="Simple text",
									text="TEXTtext 0123456789_",
									text2 = "TEXTtext abc,deFG.Hij!? Klm^-^  01234789_", -- this is all the characters that can be saved as string
									PERMANENT_test01 = false,
									testnil = nil 		--### This Will be turn to "testnil = false"
									foo_nil = "somethin" -- THIS IS NOT VALID
									nil_ = "somethin" -- THIS IS NOT VALID
									anil_ = "somethin" -- THIS IS OK but not recomended
									nila_ = "somethin" -- THIS IS OK but not recomended
								}
	--]]

	function initial_data_init()
	local g_vars = [[
		local g_vars =	{ 	-- Here goes the global variables( that will be saved )
									-- prefix variables with "PERMANENT_" to keep thos variables out of the 'newgame vars reset' (for challenge or anything you want to be permanently saved)
									PERMANENT_test01 = nil,
									PERMANENT_test02 = nil,
									PERMANENT_test03 = nil,
									GlobalSeed = 0,
									MoneyIsPower_OldCoins = 0,
									hot_pizza_slice_HpUp_Done = false,
									tech0_oldFrame = 0,
									tech0_n = 1.0,
									blindPact_pickedItem = 0,
									blindPact_previousItem = 0,
									blindPact_previousStage = 0,
									cricketsPaw_Uses = 0,
									cricketsPaw_had= false,
									solomon_taken = false,
									solomon_StatUpOnce = false,
									BubblesHead_ShootedTears = 0,
									BubblesHead_oldFrame = 0,
									FAM_SunWukongExists = false,
									FAM_SunWukongCounter = 0,
									FAM_SunWukong_oldFrame = 0,
									FAM_BombBumExists = false,
									FAM_BombCounter = 0,
									FAM_nBombBeforDrop = 10,
									FirstBlood_Done = false,
									hasElectronSpawned = false,
									numberOfElectrons = 0,
									transcricket_hasTransfo = false,
									transcricket_hasCostume = false,
									translaser_hasTransfo = false,
									translaser_hasCostume = false,
									greencross_lastRoom = nil,
									chora_hasCostume = true
								}
		return g_vars
	]]
		return load( g_vars:gsub("(%A)nil(%A)", "%1false%2") )()
	end
	g_vars = initial_data_init()

	require("luafiles/save_load.lua")
	local s = _load_() -- Load
	Isaac.DebugString(">>> Save Normal Size:" .. tostring(table._getn(g_vars)) .. " || Current Size:" .. tostring(table._getn(s)))
	 -- If save found and correct size then restore it else reset
	if s and table._getn(g_vars) == table._getn(s) then data_init_load(s); Isaac.DebugString(">>> Save restored") else Isaac.DebugString(">>> Save reset: size = " .. tostring(table._getn(g_vars))) end

	require("luafiles/characters/character_init.lua")
	require("luafiles/init.lua")
	--require("luafiles/debugtext.lua")

	require("luafiles/items/collectibles.lua")

	require("luafiles/items/familiars.lua")

	require("luafiles/items/trinkets.lua")
	require("luafiles/transformations/transfo.lua")
end
