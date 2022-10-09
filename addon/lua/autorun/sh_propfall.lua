local maps = {
	["gm_propfall"] = true,
	["gm_propfall_slopes"] = true
}

if !maps[game.GetMap()] or PropFall != nil then return end

if SERVER then
	include("propfall/sh_propfall.lua")

	include("propfall/server/sv_config.lua")
	include("propfall/server/sv_propfall.lua")
	include("propfall/server/sv_shop.lua")
	include("propfall/server/sv_anticheat.lua")
	include("propfall/server/sv_optimizations.lua")

	AddCSLuaFile("propfall/sh_propfall.lua")

	AddCSLuaFile("propfall/client/cl_propfall.lua")
	AddCSLuaFile("propfall/client/cl_shop.lua")

	local f, folder = file.Find("propfall/shop/*", "LUA")
	for k=1, #f do
		include("propfall/shop/" .. f[k])
		AddCSLuaFile("propfall/shop/" .. f[k])
	end
else
	include("propfall/sh_propfall.lua")
	include("propfall/client/cl_propfall.lua")
	include("propfall/client/cl_shop.lua")

	local f, folder = file.Find("propfall/shop/*", "LUA")
	for k=1, #f do
		include("propfall/shop/" .. f[k])
	end
end