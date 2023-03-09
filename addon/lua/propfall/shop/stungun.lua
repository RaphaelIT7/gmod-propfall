local Item = {}
Item.Price = 10
Item.Weapon = "weapon_stungun"
Item.Icon = "propfall/shop/stungun.png"
Item.Name = "Stun Gun"
Item.Description = "Shoot a player to slow him down. \nDuration: 5 seconds \nAmmo: 3 Shoots"

function Item:OnBuy(ply)
	ply:Give(Item.Weapon)
end

PropFall.AddItem(Item)