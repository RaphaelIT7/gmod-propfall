PropFall = PropFall or {}
PropFall.Items = PropFall.Items or {}
PropFall.Colors = {
	["Default"] = Color(100, 100, 100, 255),
	["Background"] = Color(150, 150, 150, 255),
	["Text"] = Color(50, 50, 50, 255),
 	["Hovered"] = Color(200, 50, 50, 255),
	["Outline"] = Color(50, 50, 50, 255),
	["Orange"] = Color(255, 165, 0, 255),
	["Button"] = Color(75, 75, 75, 255),
	["Halo"] = Color(255, 0, 0, 255),
}

function PropFall.AddItem(Item)
	local i = -1
	for k, v in ipairs(PropFall.Items) do
		if v.Name == Item.Name then
			i = k
			break
		end
	end

	if i != -1 then
		PropFall.Items[i] = Item
		return
	end

	PropFall.Items[#PropFall.Items + 1] = Item
end

if SERVER then
	util.AddNetworkString("PropFall_Notify")
	local meta = FindMetaTable("Player")
	function meta:PropFall_Notify(text, type, length)
		net.Start("PropFall_Notify")
			net.WriteString(text)
			net.WriteUInt(type, 3)
			net.WriteUInt(length, 8)
		net.Send(self)
	end

	function PropFall.Notify(text, type, length)
		net.Start("PropFall_Notify")
			net.WriteString(text)
			net.WriteUInt(type, 3)
			net.WriteUInt(length, 8)
		net.Broadcast()
	end
else
	net.Receive("PropFall_Notify", function()
		local text = net.ReadString()
		local type = net.ReadUInt(3)
		local length = net.ReadUInt(8)
		if text == "" or type == 0 or length == 0 then return end
		notification.AddLegacy(text, type, length)
	end)
end
