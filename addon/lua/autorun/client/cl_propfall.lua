if game.GetMap() != "gm_propfall" then return end

function surface.DrawFullCircle(x, y, radius, seg)
	local cir = {}

	table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})
	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})
	end
	local a = math.rad(0) -- This is needed for non absolute segment counts
	table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})
	surface.DrawPoly(cir)
end

local FinishPos = FinishPos
local StartPos = StartPos
local FinishDistance = FinishDistance
local highscore = highscore
timer.Simple(0, function()
	FinishPos = GetGlobalVector("PropFall.FinishPos")
	StartPos = GetGlobalVector("PropFall.StartPos")
	FinishDistance = FinishPos:Distance(Vector(StartPos[1], FinishPos[2], StartPos[3]))
	highscore = FinishDistance
end)

hook.Add("HUDPaint", "PropFall.TimeLeft", function()

	// Distance
	local pos = LocalPlayer():GetPos()
	local vec = Vector(pos[1], FinishPos[2], pos[3])
	local dist = LocalPlayer():GetNWBool("Finished") and 15 or vec:Distance(FinishPos)
	highscore = LocalPlayer():GetNWBool("Finished") and 24912 or highscore >= dist and dist or highscore	
	local ScaleW = ScrW() / 1920
	local ScaleH = ScrH() / 1080
	local a = 25 * ScaleW
	local b = 5 * ScaleH
	local c = 5 * ScaleW
	local d = 112.5 * ScaleW
	local e = 102.5 * ScaleW
	surface.SetDrawColor(100, 100, 100, 255)
	surface.DrawRect(ScrW() - d, (ScrH() / 10) * ScaleH, a, b)
	surface.DrawRect(ScrW() - d, (ScrH() / 10 + FinishDistance / 28 + 10) * ScaleH, a, b)
	surface.DrawRect(ScrW() - e, (ScrH() / 10) * ScaleH, c, math.Clamp(dist / 28, 0, 860) * ScaleH)

	if !LocalPlayer():GetNWBool("Finished") then
		surface.SetDrawColor( 255, 0, 0, 255)
		surface.DrawFullCircle(ScrW() - (100 * ScaleW), (ScrH() / 10 + math.Clamp(highscore / 28, 13, 845)) * ScaleH, 10 * ScaleW, 10 * ScaleH)
		surface.DrawRect(ScrW() - e, (ScrH() / 10 + math.Clamp(highscore / 28, 15, 845)) * ScaleH, c, (858 - math.Clamp(highscore / 28, 13, 845)) * ScaleH)
	end

	surface.SetDrawColor(0, 255, 0, 255)
	surface.DrawRect(ScrW() - e, (ScrH() / 10 + math.Clamp(dist / 28, 15, 845)) * ScaleH, c, (858 - math.Clamp(dist / 28, 13, 845)) * ScaleH)
	surface.DrawFullCircle(ScrW() - (100 * ScaleW), (ScrH() / 10 + math.Clamp(dist / 28, 13, 845)) * ScaleH, 10 * ScaleW, 10 * ScaleH)

	// TimeLeft
	surface.SetFont("ChatFont")
	surface.SetTextColor(50, 50, 50, 255)
	surface.SetTextPos(ScrW() / 2 - (57  * ScaleW), (ScrH() / 40) * ScaleH)
	surface.DrawText("Timeleft : " .. string.FormattedTime(GetGlobalInt("PropFall.TimeLeft"), "%02i:%02i"), false)
end)

local frame = frame or nil
net.Receive("PropFall.Vote", function()
	local bool = net.ReadBool()
	if bool and IsValid(frame) then
		frame:Close()
		return
	end

	if IsValid(frame) then
		frame:Close()
	end

	frame = vgui.Create("DFrame")
	frame:SetSize(500, 200)
	frame:SetTitle("Difficulty Selection")
	frame:ParentToHUD()
	frame:Center()
	frame:MakePopup()
	frame:ShowCloseButton(false)
	frame.OnRemove = function()
		timer.Remove("Easy.Button")
		timer.Remove("Medium.Button")
		timer.Remove("Hard.Button")
		timer.Remove("Insane.Button")
		timer.Remove("Easy.Votes")
		timer.Remove("Medium.Votes")
		timer.Remove("Hard.Votes")
		timer.Remove("Insane.Votes")
		timer.Remove("Timeleft")
	end

	local title = vgui.Create("DLabel", frame)
	title:SetSize(frame:GetWide(), 20)
	title:SetPos(0, 20)
	title:SetText("Select a Difficulty for the next Round")
	title:SetContentAlignment(5)

	local timeleft = vgui.Create("DLabel", frame)
	timeleft:SetSize(frame:GetWide(), 20)
	timeleft:SetPos(0, 30)
	timeleft:SetContentAlignment(5)
	timeleft:SetText("Time to Vote : 00:00")

	timer.Create("Timeleft", 1, -1, function()
		timeleft:SetText("Time to Vote : " .. string.FormattedTime(GetGlobalInt("PropFall.VoteTime"), "%02i:%02i"))
	end)

	local default = Color(150, 150, 150, 255)
	local background = Color(100, 100, 100, 255)
	local textcolor = Color(50, 50, 50, 255)
	local selected

		local easy = vgui.Create("DPanel", frame)
		easy:SetPos(15, 55)
		easy:SetSize(110, 130)
		easy.Paint = function() end

			local button = vgui.Create("DButton", easy)
			button:SetSize(easy:GetWide(), easy:GetTall() / 1.5)
			button:SetText("Easy")
			button:SetFont("DermaLarge")
			button:SetTextColor(textcolor)
			button.i = 2
			button.last = CurTime()
			button.Paint = function(self, w, h)
				surface.SetDrawColor(default)
				if self:IsHovered() or selected == self then
					surface.DrawOutlinedRect(0, 0, w, h, math.floor(math.sin(self.last * 2) * 8) + 10 )
				end
				surface.DrawOutlinedRect(0, 0, w, h, 2)
			end
			button.DoClick = function()
				net.Start("PropFall.Vote")
					net.WriteUInt(1, 3)
				net.SendToServer()
				selected = button
			end

			timer.Create("Easy.Button", 0.02, -1, function()
				if button:IsHovered() or selected == button then
					button.last = button.last + 0.02
				end
			end)

			local votes = vgui.Create("DLabel", easy)
			votes:SetSize(easy:GetWide(), 20)
			votes:SetPos(0, easy:GetTall() / 1.4)
			votes:SetContentAlignment(5)
			votes:SetText("Votes : ")
			votes.Paint = function(self, w, h)
				surface.SetDrawColor(default)
				surface.DrawOutlinedRect(0, 0, w, h, 2)
				surface.SetDrawColor(background)
				surface.DrawRect(2, 2, w - 4, h - 4)
				surface.SetDrawColor(default)
			end

			timer.Create("Easy.Votes", 0.02, -1, function()
				votes:SetText("Votes : " .. GetGlobalInt("PropFall.Votes.Easy"))
			end)

		local medium = vgui.Create("DPanel", frame)
		medium:SetPos(135, 55)
		medium:SetSize(110, 130)
		medium.Paint = function() end

			local button = vgui.Create("DButton", medium)
			button:SetSize(medium:GetWide(), medium:GetTall() / 1.5)
			button:SetText("Medium")
			button:SetFont("DermaLarge")
			button:SetTextColor(textcolor)
			button.i = 2
			button.last = CurTime()
			button.Paint = function(self, w, h)
				if self:IsHovered() or selected == self then
					surface.DrawOutlinedRect(0, 0, w, h, math.floor(math.sin(self.last * 2) * 8) + 10 )
				end
				surface.DrawOutlinedRect(0, 0, w, h, 2)
			end
			button.DoClick = function()
				net.Start("PropFall.Vote")
					net.WriteUInt(2, 3)
				net.SendToServer()
				selected = button
			end

			timer.Create("Medium.Button", 0.02, -1, function()
				if button:IsHovered() or selected == button then
					button.last = button.last + 0.02
				end
			end)

			local votes = vgui.Create("DLabel", medium)
			votes:SetSize(medium:GetWide(), 20)
			votes:SetPos(0, medium:GetTall() / 1.4)
			votes:SetContentAlignment(5)
			votes:SetText("Votes : ")
			votes.Paint = function(self, w, h)
				surface.SetDrawColor(default)
				surface.DrawOutlinedRect(0, 0, w, h, 2)
				surface.SetDrawColor(background)
				surface.DrawRect(2, 2, w - 4, h - 4)
				surface.SetDrawColor(default)
			end

			timer.Create("Medium.Votes", 0.02, -1, function()
				votes:SetText("Votes : " .. GetGlobalInt("PropFall.Votes.Medium"))
			end)


		local hard = vgui.Create("DPanel", frame)
		hard:SetPos(255, 55)
		hard:SetSize(110, 130)
		hard.Paint = function() end

			local button = vgui.Create("DButton", hard)
			button:SetSize(hard:GetWide(), hard:GetTall() / 1.5)
			button:SetText("Hard")
			button:SetFont("DermaLarge")
			button:SetTextColor(textcolor)
			button.i = 2
			button.last = CurTime()
			button.Paint = function(self, w, h)
				if self:IsHovered() or selected == self then
					surface.DrawOutlinedRect(0, 0, w, h, math.floor(math.sin(self.last * 2) * 8) + 10 )
				end
				surface.DrawOutlinedRect(0, 0, w, h, 2)
			end
			button.DoClick = function()
				net.Start("PropFall.Vote")
					net.WriteUInt(3, 3)
				net.SendToServer()
				selected = button
			end

			timer.Create("Hard.Button", 0.02, -1, function()
				if button:IsHovered() or selected == button then
					button.last = button.last + 0.02
				end
			end)

			local votes = vgui.Create("DLabel", hard)
			votes:SetSize(hard:GetWide(), 20)
			votes:SetPos(0, hard:GetTall() / 1.4)
			votes:SetContentAlignment(5)
			votes:SetText("Votes : ")
			votes.Paint = function(self, w, h)
				surface.SetDrawColor(default)
				surface.DrawOutlinedRect(0, 0, w, h, 2)
				surface.SetDrawColor(background)
				surface.DrawRect(2, 2, w - 4, h - 4)
				surface.SetDrawColor(default)
			end

			timer.Create("Hard.Votes", 0.02, -1, function()
				votes:SetText("Votes : " .. GetGlobalInt("PropFall.Votes.Hard"))
			end)

		local insane = vgui.Create("DPanel", frame)
		insane:SetPos(375, 55)
		insane:SetSize(110, 130)
		insane.Paint = function() end

			local button = vgui.Create("DButton", insane)
			button:SetSize(insane:GetWide(), insane:GetTall() / 1.5)
			button:SetText("Insane")
			button:SetFont("DermaLarge")
			button:SetTextColor(textcolor)
			button.i = 2
			button.last = CurTime()
			button.Paint = function(self, w, h)
				if self:IsHovered() or selected == self then
					surface.DrawOutlinedRect(0, 0, w, h, math.floor(math.sin(self.last * 2) * 8) + 10 )
				end
				surface.DrawOutlinedRect(0, 0, w, h, 2)
			end
			button.DoClick = function()
				net.Start("PropFall.Vote")
					net.WriteUInt(4, 3)
				net.SendToServer()
				selected = button
			end

			timer.Create("Insane.Button", 0.02, -1, function()
				if button:IsHovered() or selected == button then
					button.last = button.last + 0.02
				end
			end)

			local votes = vgui.Create("DLabel", insane)
			votes:SetSize(insane:GetWide(), 20)
			votes:SetPos(0, insane:GetTall() / 1.4)
			votes:SetContentAlignment(5)
			votes:SetText("Votes : ")
			votes.Paint = function(self, w, h)
				surface.SetDrawColor(default)
				surface.DrawOutlinedRect(0, 0, w, h, 2)
				surface.SetDrawColor(background)
				surface.DrawRect(2, 2, w - 4, h - 4)
				surface.SetDrawColor(default)
			end

			timer.Create("Insane.Votes", 0.02, -1, function()
				votes:SetText("Votes : " .. GetGlobalInt("PropFall.Votes.Insane"))
			end)
end)

net.Receive("PropFall.End", function()
	local top3 = net.ReadTable()
	local matBlurScreen = Material("pp/blurscreen")
	for a=1, #top3 do
		local ply = top3[a][1]
		if !IsValid(ply) then return end
		top3[a][1] = ply:Nick()
		top3[a][2] = ply:GetNWInt("Time")
	end
	local first_time = string.format(top3[1][2], "%02i:%02i")
	local second_time = string.format(top3[2][2], "%02i:%02i")
	local third_time = string.format(top3[3][2], "%02i:%02i")
	local time = LocalPlayer():GetNWInt("Time")
	PrintTable(top3)
	hook.Add("HUDPaint", "PropFall.Winners", function()
		surface.SetMaterial(matBlurScreen)
		surface.SetDrawColor(255, 255, 255, 255)

		for i=0.33, 1, 0.33 do
			matBlurScreen:SetFloat( "$blur", 1 * 5 * i )
			matBlurScreen:Recompute()
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH() )
		end

		surface.SetDrawColor(200, 200, 200, 240)
		surface.DrawRect(ScrW() / 12, ScrH() / 12, ScrW() / 1.2, ScrH() / 1.2)

		if time != 0 then
			surface.SetFont("DermaLarge")
			surface.SetTextColor(0, 0, 0, 255)
			surface.SetTextPos(ScrW() / 2.3, ScrH() / 10)
			surface.DrawText("You're Time : " .. string.FormattedTime(time, "%02im %02is"))
		end

		surface.SetDrawColor(212, 175, 55, 255)
		surface.DrawRect((ScrW() / 2 - (ScrW() / 20) / 2), ScrH() / 3, ScrW() / 20, ScrH() / 1.712)

		surface.SetTextPos(ScrW() / 2.014, ScrH() / 2.5)
		surface.DrawText("1")

		surface.SetTextPos(ScrW() / 2.07, ScrH() / 3.0)
		surface.DrawText(first_time)

		surface.SetTextPos(ScrW() / 2.1, ScrH() / 3.28)
		surface.DrawText(top3[1][1])

		surface.SetDrawColor(168, 169, 173, 255)
		surface.DrawRect((ScrW() / 3 - (ScrW() / 20) / 2), ScrH() / 2.158, ScrW() / 20, ScrH() / 2.2)

		surface.SetTextPos(ScrW() / 3.04, ScrH() / 1.9)
		surface.DrawText("2")

		surface.SetTextPos(ScrW() / 3.17, ScrH() / 2.15)
		surface.DrawText(second_time)

		surface.SetTextPos(ScrW() / 3.25, ScrH() / 2.3)
		surface.DrawText(top3[2][1])

		surface.SetDrawColor(137, 73, 39, 255)
		surface.DrawRect((ScrW() / 1.5 - (ScrW() / 20) / 2), ScrH() / 1.6, ScrW() / 20, ScrH() / 3.4)

		surface.SetTextPos(ScrW() / 1.51, ScrH() / 1.45)
		surface.DrawText("3")

		surface.SetTextPos(ScrW() / 1.54, ScrH() / 1.6)
		surface.DrawText(third_time)

		surface.SetTextPos(ScrW() / 1.56, ScrH() / 1.68)
		surface.DrawText(top3[3][1])
	end)
	timer.Simple(10, function()
		hook.Remove("HUDPaint", "PropFall.Winners")
	end)
end)

net.Receive("PropFall.Death", function()
	local Ent = {[1] = net.ReadEntity()}
	local HaloColor = Color(255, 0, 0, 255)
	hook.Add("PreDrawHalos", "PropFall.DeathHalo", function()
		halo.Add(Ent, HaloColor, 10, 10, 5, true, true)
	end)

	timer.Simple(5, function()
		hook.Remove("PreDrawHalos", "PropFall.DeathHalo")
	end)
end)
