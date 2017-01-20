--[[
a besoin de  '--luadebug' ...
--]]
--Mod
AfterBrasse = RegisterMod("AfterBrasse", 1)
Items = {
				MoneyLuck_i = Isaac.GetItemIdByName( "Money = Luck" ),
				Beer_i = Isaac.GetItemIdByName( "Beer" ),
				CricketsPaw_i = Isaac.GetItemIdByName( "Cricket's Paw" ),
				brave_shoe_i = Isaac.GetItemIdByName("Brave Shoe");
}

local _f = io.open("savedatapath.txt", "r")
local _data = _f:read("*all"); _f:close()
local _, _e = string.find(_data, "Modding Data Path: ")
local _path = string.match(string.sub(_data, _e+1, #_data),  "^@?(.+/)[^/]+$")
local include = function(file) local _Npath = _path .."/"..AfterBrasse.Name.."/"..file dofile(_Npath) end

include("srcs/test_debug") --comment this line to disable cheats
include("srcs/items/cricketspaw.lua")
include("srcs/items/moneyisluck.lua")
include("srcs/items/beer.lua")
include("srcs/items/braveshoe.lua")
--[[
require("srcs.test_debug") --comment this line to disable cheats
require("srcs.items.cricketspaw.lua")
require("srcs.items.moneyisluck.lua")
require("srcs.items.beer.lua")
require("srcs.items.braveshoe.lua")
--]]
