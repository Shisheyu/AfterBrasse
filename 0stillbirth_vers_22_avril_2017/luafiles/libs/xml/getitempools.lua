#!/usr/bin/env lua

function GetItemPools(filename)
	dofile("xml.lua")
	dofile("handler.lua")
	if filename == nil then
		filename = "itempools.xml"
	end
	local xmltext = ""
	local POOLS = {}
	local f, e = io.open(filename, "r")
	if f then
	  --Gets the entire file content and stores into a string
	  xmltext = f:read("*a")
	else
	  error(e)
	end

	--Instantiate the object the states the XML file as a Lua table
	local xmlhandler = simpleTreeHandler()

	--Instantiate the object that parses the XML to a Lua table
	local xmlparser = xmlParser(xmlhandler)
	xmlparser:parse(xmltext)
	for key, pool in pairs(xmlhandler.root.ItemPools.Pool) do
		POOLS[pool._attr.name] = {}
	end
	for key, pool in pairs(xmlhandler.root.ItemPools.Pool) do
		tmp = {}
		for key1, item in ipairs(pool) do
			table.insert(tmp, tonumber(item.Item._attr.Id))
		end
		POOLS[pool._attr.name] = tmp
	end
	return POOLS
end

pool = GetItemPools(nil)
for i=1, #pool.beggar do
	print(pool.beggar[i])
end
