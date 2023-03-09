local Item = {}
Item.Price = 10
Item.Weapon = "weapon_adrenaline"
Item.Icon = "propfall/shop/adrenaline.png"
Item.Name = "Adrenaline"
Item.Description = "use this to receive a 50% Speedboost. \nDuration: 10 Seconds"

function Item:OnBuy(ply)
	ply:Give(Item.Weapon) 
end

PropFall.AddItem(Item)