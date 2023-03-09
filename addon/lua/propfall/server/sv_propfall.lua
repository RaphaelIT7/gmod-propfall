util.AddNetworkString("PropFall.Vote")
util.AddNetworkString("PropFall.Death")
util.AddNetworkString("PropFall.End")

resource.AddWorkshop("2840359110") -- Needed for the Content

local IsValid = IsValid
local reg = debug.getregistry()
local GetPos = reg.Entity.GetPos
local FindByName = ents.FindByName
local FindByClass = ents.FindByClass
timer.Simple(0, function()
	SetGlobal2Vector("PropFall.FinishPos", FindByName("PropFall_FinishLine")[1]:GetPos())
	SetGlobal2Vector("PropFall.StartPos", FindByName("PropFall_StartLine")[1]:GetPos())

	local Spawners = FindByName("PropFall_Spawner")
	for k=1, #Spawners do
		if !IsValid(Spawners[k]) then return end
		PropFall.Spawners[#PropFall.Spawners + 1] = GetPos(Spawners[k])
	end

	local Spawns = FindByClass("info_player_start")
	for k=1, #Spawns do
		if !IsValid(Spawns[k]) then return end
		PropFall.Spawns[#PropFall.Spawns + 1] = GetPos(Spawns[k])
	end
end)

local Create = ents.Create
local random = math.random
local Spawn = reg.Entity.Spawn
local SetPos = reg.Entity.SetPos
local SetModel = reg.Entity.SetModel
local GetPhysicsObject = reg.Entity.GetPhysicsObject
local SetCustomCollisionCheck = reg.Entity.SetCustomCollisionCheck
PropFall.Spawn = function()
	local ent = Create("prop_physics")
	SetModel(ent, PropFall.Models[random(1, #PropFall.Models)])
	SetPos(ent, PropFall.Spawners[random(1, #PropFall.Spawners)])
	Spawn(ent)
	SetCustomCollisionCheck(ent, true)
	ent.PropFall = true
	local phys = GetPhysicsObject(ent)
	phys:SetMass(1000)
	phys:SetMaterial("gmod_bouncy")
end

-- If we dont't do this Gmod will freeze the Props automaticly
local Wake = reg.PhysObj.Wake
hook.Add("Think", "PropFall.AntiFreeze", function()
	local entities = FindByClass("prop_physics")
	for k=1, #entities do
		Wake(GetPhysicsObject(entities[k]))
	end
end)

hook.Add("PlayerLoadout", "PropFall.NoLoadout", function()
	return true
end)

hook.Add("Initialize", "PropFall.Initialize", function()
	PropFall.Waiting()
end)

PropFall.Spawner = function(mode)
	timer.Create("PropFall.Spawner", 1 / PropFall.Difficulty[mode], -1, function()
		PropFall.Spawn()
	end)
end

local HUD_PRINTCENTER = HUD_PRINTCENTER
local DMG_RADIATION = DMG_RADIATION
PropFall.Start = function()
	PropFall.Round.Status = PropFall.Started
	hook.Run("PropFall.Status", PropFall.Round.Status)

	PropFall.Round.TimeLeft = PropFall.TimeLeft
	timer.Create("PropFall.Timer", 1, -1, function()
		if !PropFall.Round.TimeLeft then
			timer.Remove("PropFall.Spawner")
			timer.Remove("PropFall.Timer")
			return
		end

		PropFall.Round.TimeLeft = PropFall.Round.TimeLeft - 1
		SetGlobal2Int("PropFall.TimeLeft", PropFall.Round.TimeLeft)
		if PropFall.Round.TimeLeft == 0 then
			PropFall.Finish()
		end
	end)
	
	hook.Add("EntityTakeDamage", "PropFall.Finish", function(ply, info)
		if info:GetDamageType() != DMG_RADIATION then return end
		if !ply:GetNW2Bool("PropFall.Finished") then
			PropFall.Round.Finishers[#PropFall.Round.Finishers + 1] = ply
			ply:SetNW2Bool("PropFall.Finished", true)
			ply:SetNWInt("PropFall.Time", PropFall.TimeLeft - PropFall.Round.TimeLeft)
			PrintMessage(HUD_PRINTTALK, ply:Nick() .. " has reached the Top")
			if #PropFall.Round.Finishers == player.GetCount() then
				PropFall.Finish()
			elseif #PropFall.Round.Finishers == 1 then
				PrintMessage(HUD_PRINTCENTER, "you have 1 minute left")
				PropFall.Round.TimeLeft = 60
			end
		end

		return true
	end)

	hook.Add("PlayerSpawn", "PropFall.Spawn", function(ply)
		timer.Simple(0.1, function()
			ply:SetWalkSpeed(PropFall.WalkSpeed)
			ply:SetRunSpeed(PropFall.RunSpeed)
		end)
	end)

	hook.Add("DoPlayerDeath", "PropFall.Death", function(ply, ent)
		net.Start("PropFall.Death")
			net.WriteEntity(ent)
		net.Send(ply)
	end)

	hook.Add("PlayerNoClip", "PropFall.Noclip", function(ply)
		return ply:GetNW2Bool("PropFall.Finished")
	end)
end

PropFall.Finish = function()
	timer.Remove("PropFall.Spawner")
	timer.Remove("PropFall.Timer")
	hook.Remove("DoPlayerDeath", "PropFall.Death")
	hook.Remove("PlayerNoClip", "PropFall.Noclip")
	hook.Remove("EntityTakeDamage", "PropFall.Finish")
	SetGlobal2Int("PropFall.TimeLeft", 0)
	PropFall.Round.Status = PropFall.Finished
	hook.Run("PropFall.Status", PropFall.Round.Status)

	if #PropFall.Round.Finishers > 0 then
		if #PropFall.Round.Finishers > 2 then
			local top3 = {}
			for a = 1, 3 do
				top3[a] = {}
				top3[a][1] = nil
			end

			for a = 1, 3 do
				if a > #PropFall.Round.Finishers then continue end
				local searching = true

				top3[a][1] = PropFall.Round.Finishers[a]
			end
			net.Start("PropFall.End")
				net.WriteTable(top3)
			net.Broadcast()
		else
			local k = 1
			while !IsValid(PropFall.Round.Finishers[k]) and k < player.GetCount() do -- if the first entry is invalid then check the next
				k = k + 1
			end
			PrintMessage(HUD_PRINTCENTER, "The Winner is " .. PropFall.Round.Finishers[k]:Nick())
		end
	else
		PrintMessage(HUD_PRINTCENTER, "There is no Winner")
	end

	timer.Simple(10, function()
		for k=1, #PropFall.Round.Finishers do
			PropFall.Round.Finishers[k]:SetNW2Bool("PropFall.Finished", false)
		end
		PropFall.Waiting()
	end)
end

local MOVETYPE_WALK = MOVETYPE_WALK
local MOVETYPE_NONE = MOVETYPE_NONE
PropFall.CountDown = function(mode)
	timer.Remove("PropFall.Spawner")
	timer.Remove("PropFall.Timer")
	hook.Remove("DoPlayerDeath", "PropFall.Death")
	hook.Remove("PlayerNoClip", "PropFall.Noclip")
	hook.Remove("EntityTakeDamage", "PropFall.Finish")
	SetGlobal2Int("PropFall.TimeLeft", PropFall.TimeLeft)
	PropFall.Round.Status = PropFall.Starting
	hook.Run("PropFall.Status", PropFall.Round.Status)
	PropFall.Spawner(mode)

	local entities = FindByClass("prop_physics")
	for k=1, #entities do
		local ent = entities[k]
		ent:Remove()
	end

	local i = PropFall.StartDelay
	PrintMessage(HUD_PRINTCENTER, "Starting in " .. i)
	timer.Create("PropFall.Countdown", 1, i, function()
		i = i - 1
		PrintMessage(HUD_PRINTCENTER, "Starting in " .. i)
		if i == 0 then
			local players = player.GetAll()
			for k=1, #players do
				local ply = players[k]
				ply:SetMoveType(MOVETYPE_WALK)
				ply:SetWalkSpeed(PropFall.WalkSpeed)
				ply:SetRunSpeed(PropFall.RunSpeed)
			end
			hook.Remove("Move", "PropFall.Lobby")
			PropFall.Start()
		end
	end)
end

PropFall.Waiting = function()
	SetGlobal2Int("PropFall.Votes.Easy", 0)
	SetGlobal2Int("PropFall.Votes.Medium", 0)
	SetGlobal2Int("PropFall.Votes.Hard", 0)
	SetGlobal2Int("PropFall.Votes.Insane", 0)
	SetGlobal2Int("PropFall.StartDelay", PropFall.StartDelay)
	SetGlobal2Int("PropFall.VoteTime", 0)
	PropFall.Round = {}
	PropFall.Round.Finishers = {}
	PropFall.Round.Status = PropFall.Waiting
	hook.Run("PropFall.Status", PropFall.Waiting)

	net.Start("PropFall.Vote")
		net.WriteBool(false)
	net.Broadcast()

	hook.Add("PlayerInitialSpawn", "PropFall.Lobby", function(ply)
		PropFall.Pending_Players[ply] = function()
			timer.Simple(2, function()
				if PropFall.Round.Status != PropFall.Waiting then return end
				net.Start("PropFall.Vote")
					net.WriteBool(false)
				net.Send(ply)
			end)
		end
	end)

	local players = player.GetAll()
	for k=1, #players do
		local ply = players[k]
		ply:Spawn()
	end

	hook.Add("Move", "PropFall.Lobby", function(ply)
		ply:SetPos(PropFall.Spawns[math.random(1, #PropFall.Spawns)])
		ply:SetMoveType(MOVETYPE_NONE) 
	end)
end

gameevent.Listen("OnRequestFullUpdate")
hook.Add("OnRequestFullUpdate", "PropFall.PlayerInitialNetwork", function(data)
	local ply = Entity(data.index + 1)
	if !IsValid(ply) then return end
	local func = PropFall.Pending_Players[ply]
	if func then
		func()
		PropFall.Pending_Players[ply] = nil
	end
end)

local pairs = pairs
local SetGlobal2Int = SetGlobal2Int
net.Receive("PropFall.Vote", function(_, ply)
	local vote = net.ReadUInt(3)
	if PropFall.Round.Status != PropFall.Waiting then return end
	PropFall.Votes[ply] = vote

	-- recount
	local Easy = 0
	local Medium = 0
	local Hard = 0
	local Insane = 0
	for k, v in pairs(PropFall.Votes) do
		if v == 1 then -- Easy
			Easy = Easy + 1
		elseif v == 2 then -- Medium
			Medium = Medium + 1
		elseif v == 3 then -- Hard
			Hard = Hard + 1
		elseif v == 4 then -- Insane
			Insane = Insane + 1
		end
	end
	SetGlobal2Int("PropFall.Votes.Easy", Easy)
	SetGlobal2Int("PropFall.Votes.Medium", Medium)
	SetGlobal2Int("PropFall.Votes.Hard", Hard)
	SetGlobal2Int("PropFall.Votes.Insane", Insane)
	PropFall.Round.Easy = Easy
	PropFall.Round.Medium = Medium
	PropFall.Round.Hard = Hard
	PropFall.Round.Insane = Insane

	if Easy > 0 or Medium > 0 or Hard > 0 or Insane > 0 then
		if !timer.Exists("PropFall.Voting") then
			local time = (Easy + Medium + Hard + Insane) == player.GetCount() and 5 or PropFall.VoteTime
			timer.Create("PropFall.Voting", 1, time, function()
				SetGlobal2Int("PropFall.VoteTime", time)
				time = time - 1
				if time == 0 then
					local Easy = 0
					local Medium = 0
					local Hard = 0
					local Insane = 0
					for k, v in pairs(PropFall.Votes) do
						if v == 1 then -- Easy
							Easy = Easy + 1
						elseif v == 2 then -- Medium
							Medium = Medium + 1
						elseif v == 3 then -- Hard
							Hard = Hard + 1
						elseif v == 4 then -- Insane
							Insane = Insane + 1
						end
					end
					local highest = {[1] = Easy, [2] = "Easy"}
					if Medium > highest[1] then
						highest[1] = Medium
						highest[2] = "Medium"
					end
					if Hard > highest[1] then
						highest[1] = Hard
						highest[2] = "Hard"
					end
					if Insane > highest[1] then
						highest[1] = Insane
						highest[2] = "Insane"
					end

					net.Start("PropFall.Vote")
						net.WriteBool(true)
					net.Broadcast()
					hook.Remove("PlayerInitialSpawn", "PropFall.Lobby")
					PropFall.CountDown(highest[2])
				end
			end)
		else
			if (Easy + Medium + Hard + Insane) == player.GetCount() then
				timer.Adjust("PropFall.Voting", 1, 5)
			end
		end
	end
end)