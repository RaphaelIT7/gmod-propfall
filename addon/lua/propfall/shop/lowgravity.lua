local Item = {}
Item.Price = 15
Item.Weapon = ""
Item.Icon = "propfall/shop/lowgravity.png"
Item.Name = "Low Gravity"
Item.Description = "Experience 10% of the normal Gravity. \nDuration: until you die or round ends"

function Item:OnBuy(ply)
	ply:SetGravity(0.1)
	ply.LowGravity = true
end

hook.Add("PlayerDeath", "PropFall.Item.LowGravity", function(victim)
	if victim.LowGravity then
		victim:SetGravity(1)
		victim.LowGravity = nil
	end
end)

hook.Add("PropFall.Status", "PropFall.Item.LowGravity", function(status)
	if status == PropFall.Finished then
		local plys = player.GetAll()
		for k=1, #plys do
			local ply = plys[k]
			ply:SetGravity(1)
			ply.LowGravity = nil
		end
	end
end)

PropFall.AddItem(Item)