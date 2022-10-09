net.Receive("PropFall.Points", function()
	notification.AddLegacy("You received one point.", NOTIFY_HINT, 3)
end)

hook.Add("KeyPress", "PropFall.Shop", function(_, KEY)
	if KEY == IN_USE then
		if GetGlobalInt("PropFall.TimeLeft") == 0 then
			LocalPlayer():ChatPrint("You cannot use the shop right now!")
		else
			local shop = vgui.Create("DFrame")
			shop:SetSize(ScrW() / 4, ScrH() / 2)
			shop:Center()
			shop:MakePopup()
			shop:ParentToHUD()
			shop:SetTitle("Propfall - Pointshop")
			shop:SetDraggable(false)
			shop:ShowCloseButton(false)
			shop.Paint = function(self, w, h)
				surface.SetDrawColor(PropFall.Colors["Default"])
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(PropFall.Colors["Orange"])
				surface.DrawLine(1, 28, w - 2, 28)

				surface.SetDrawColor(PropFall.Colors["Outline"])
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end

			PropFall.Shop = shop

			local close = vgui.Create("DButton", shop)
			close:SetSize(40, 20)
			close:SetPos(shop:GetWide() - 44, 4)
			close:SetText("r")
			close:SetFont("Marlett")
			close:SetTextColor(Color(50, 50, 50, 255))
			close.Paint = function(self, w, h)
				surface.SetDrawColor(self:IsHovered() and PropFall.Colors["Hovered"] or PropFall.Colors["Default"])
				surface.DrawRect(0, 0, w, h)
			end
			close.DoClick = function()
				surface.PlaySound("ui/buttonclick.wav")
				shop:Remove()
			end

			local welcome = vgui.Create("DLabel", shop)
			welcome:SetSize(shop:GetWide() / 1.2, shop:GetTall() / 6)
			welcome:SetPos(5, 10)
			welcome:SetFont("Trebuchet18")
			welcome:SetContentAlignment(5)
			welcome:SetText("Welcome to the Pointshop.\nyou can buy one-time items with points you received.")

			local points = vgui.Create("DLabel", shop)
			points:SetSize(shop:GetWide() / 1.2, shop:GetTall() / 6)
			points:SetPos(shop:GetWide() / 10, shop:GetTall() / 10)
			points:SetFont("Trebuchet18")
			points:SetText("You currently have " .. LocalPlayer():GetNW2Int("PropFall.Points") .. " points")

			local items = vgui.Create("DPanel", shop)
			items:SetSize(shop:GetWide() / 2.05, shop:GetTall() / 1.5)
			items:SetPos(5, shop:GetTall() - (items:GetTall() + 5))
			items.Paint = function(self, w, h)
				surface.SetDrawColor(PropFall.Colors["Default"])
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(PropFall.Colors["Orange"])
				surface.DrawLine(1, 28, w - 2, 28)

				surface.SetDrawColor(PropFall.Colors["Outline"])
				surface.DrawOutlinedRect(0, 0, w, h, 1)

				draw.DrawText("Weapons", "ChatFont", items:GetWide() / 2, items:GetTall() / 75, PropFall.Colors["Text"], TEXT_ALIGN_CENTER)
			end

			local iteminfo = vgui.Create("DPanel", shop)
			iteminfo:SetSize(shop:GetWide() / 2.05, shop:GetTall() / 1.5)
			iteminfo:SetPos(shop:GetWide() - (iteminfo:GetWide() + 5), shop:GetTall() - (iteminfo:GetTall() + 5))
			iteminfo.Paint = function(self, w, h)
				surface.SetDrawColor(PropFall.Colors["Default"])
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(PropFall.Colors["Orange"])
				surface.DrawLine(1, 28, w - 2, 28)

				surface.SetDrawColor(PropFall.Colors["Outline"])
				surface.DrawOutlinedRect(0, 0, w, h, 1)

				draw.DrawText("Information", "ChatFont", iteminfo:GetWide() / 2, iteminfo:GetTall() / 75, PropFall.Colors["Text"], TEXT_ALIGN_CENTER)
			end

			local item_name = vgui.Create("DLabel", iteminfo)
			item_name:SetFont("TargetID")
			item_name:SetSize(iteminfo:GetWide() - 8, iteminfo:GetTall() / 25)
			item_name:SetContentAlignment(5)
			item_name:SetPos(4, 35)
			item_name:SetTextColor(PropFall.Colors["Text"])
			item_name:SetVisible(false)

			local item_description = vgui.Create("DLabel", iteminfo)
			item_description:SetFont("Trebuchet18")
			item_description:SetSize(iteminfo:GetWide() - 8, iteminfo:GetTall() / 10)
			item_description:SetContentAlignment(5)
			item_description:SetPos(4, 70)
			item_description:SetTextColor(PropFall.Colors["Text"])
			item_description:SetVisible(false)

			local item_buy = vgui.Create("DButton", iteminfo)
			item_buy:SetFont("Trebuchet24")
			item_buy:SetSize(iteminfo:GetWide() - 8, iteminfo:GetTall() / 10)
			item_buy:SetPos(4, iteminfo:GetTall() - item_buy:GetTall() - 4)
			item_buy:SetText("Buy Item")
			item_buy:SetVisible(false)
			item_buy.itemid = nil
			item_buy.DoClick = function(self)
				net.Start("PropFall.Buy")
					net.WriteUInt(self.itemid, 3)
				net.SendToServer()
			end
			item_buy.Paint = function(self, w, h)
				surface.SetDrawColor(PropFall.Colors["Button"])
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(PropFall.Colors["Outline"])
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end


			local row = 40
			for k, v in ipairs(PropFall.Items) do
				local x = 6
				if k > 1 then
					x = x + 72
				end
				local item = vgui.Create("DImageButton", items)
				item:SetSize(64, 64)
				item:SetPos(x, row)
				item:SetImage(v.Icon)
				item:SetKeepAspect(true)
				item.DoClick = function(self)
					item_name:SetText(v.Name)
					item_name:SetVisible(true)

					item_description:SetText(v.Description)
					item_description:SetVisible(true)

					item_buy:SetVisible(true)
					item_buy.itemid = k
				end
			end
		end
	end
end)