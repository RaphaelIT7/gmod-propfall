-- Entity Index Optimization
local meta = FindMetaTable("Entity")
local GetTable = meta.GetTable
local GetOwner = meta.GetOwner
local Owner = "Owner"
function meta:__index(key)
	local val = meta[key]
	if val != nil then return val end

	local tab = GetTable(self)
	if tab then
		local val = tab[key]
		if val != nil then return val end
	end

	if key == Owner then return GetOwner(self) end

	return nil
end

hook.Add("ShouldCollide", "PropFall.AntiLag", function(ent1, ent2)
	return !(ent1.PropFall != nil and ent2.PropFall != nil)
end)