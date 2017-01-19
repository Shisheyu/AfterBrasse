--[[
--]]
--Mod
AfterBrasse = RegisterMod("AfterBrasse", 1)
Items = {
				MoneyLuck_i = Isaac.GetItemIdByName( "Money = Luck" ),
				Beer_i = Isaac.GetItemIdByName( "Beer" ),
				CricketsPaw_i = Isaac.GetItemIdByName( "Cricket's Paw" ),
				brave_shoe_i = Isaac.GetItemIdByName("Brave Shoe");
}

--[Krayz]While waiting for a working "require"... get external source anyway by using include("");
local _f = io.open("savedatapath.txt", "r")
local _data = _f:read("*all"); _f:close()
local _, _e = string.find(_data, "Modding Data Path: ")
local _path = string.match(string.sub(_data, _e+1, string.len(_data)),  "^@?(.+/)[^/]+$")
local include = function(file) local _Npath = _path .."/"..AfterBrasse.Name.."/"..file dofile(_Npath) end

include("srcs/test_debug") --[Krayz]comment this line to disable cheats
include("srcs/items/cricketspaw.lua")
include("srcs/items/moneyisluck.lua")
include("srcs/items/beer.lua")
include("srcs/items/braveshoe.lua")

