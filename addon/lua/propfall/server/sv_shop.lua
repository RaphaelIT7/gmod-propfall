util.AddNetworkString("PropFall.Buy")
hook.Add("PropFall.Status", "PropFall.Shop", function(status)
	if status == PropFall.Started then
		if !timer.Exists("PropFall.ShopPoints") then
			timer.Create("PropFall.ShopPoints", PropFall.PointDelay, -1, function()
				local plys = player.GetAll()
				for k=1, #plys do
					local ply = plys[k]
					ply:SetNW2Int("PropFall.Points", ply:GetNW2Int("PropFall.Points") + PropFall.Points)
				end

				PropFall.Notify("You received " .. PropFall.Points .. (PropFall.Points > 1 and " points." or " point."), 3, 5) -- 3 = NOTIFY_HINT
			end)
		end
	elseif status == PropFall.Finished then
		if timer.Exists("PropFall.ShopPoints") then
			timer.Remove("PropFall.ShopPoints")
		end
	end
end)

hook.Add("PlayerInitialSpawn", "PropFall.ShopInfo", function(ply)
	ply:ChatPrint("You can open the point-shop by pressing the E Key")
end)

net.Receive("PropFall.Buy", function(_, ply)
	local id = net.ReadUInt(3)
	local Item = PropFall.Items[id]
	if Item then
		local Money = ply:GetNW2Int("PropFall.Points") - Item.Price
		if Money >= 0 then
			ply:SetNW2Int("PropFall.Points", Money)
			Item:OnBuy(ply)
			ply:PropFall_Notify("You bought the Item: " .. Item.Name .. " for " .. Item.Price .. " points.", 3, 5)
		else
			ply:PropFall_Notify("You don't have enough points to buy this Item!", 1, 5)
		end
	end
end)