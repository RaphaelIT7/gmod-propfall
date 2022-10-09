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
}

function PropFall.AddItem(Item)
	PropFall.Items[#PropFall.Items + 1] = Item
end