def lua_parser(file_):
	reconstituted = ""
	for line in file_:
		if "require" in line:
			if "lua" in line:
				requirepath = line.split("require(")[1].strip(")")
				with open(requirepath, "r") as req:
					lua_parser(req)
		else:
			reconstituted += line + "\n"
	return reconstituted

if __name__ == "__main__":
	filename = "main.lua"
	re_filename = "main_oneblock.lua"
	with open(filename, "r") as f:
		re = lua_parser(f)
	with open(re_filename, "w") as f:
		f.write(re)
	pass
