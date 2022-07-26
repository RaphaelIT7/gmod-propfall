if game.GetMap() != "gm_propfall" or PropFall != nil then return end // we don't want lua autorefresh

util.AddNetworkString("PropFall.Vote")
util.AddNetworkString("PropFall.Death")

// Entity Index Optimization
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


// tables
PropFall = {}
PropFall.Models = {
	[1] = "models/xqm/jetbody3_s2.mdl",
	[2] = "models/props_phx/trains/fsd-overrun2.mdl",
	[3] = "models/XQM/coastertrain1.mdl",
	[4] = "models/props_interiors/BathTub01a.mdl",
	[5] = "models/props_interiors/Furniture_Couch01a.mdl",
	[6] = "models/props_junk/TrashBin01a.mdl",
	[7] = "models/props_interiors/Furniture_shelf01a.mdl",
	[8] = "models/props_c17/shelfunit01a.mdl",
	[9] = "models/props_junk/TrashDumpster02.mdl",
	[10] = "models/props_vehicles/truck001a.mdl",
	[11] = "models/props_trainstation/train003.mdl",
	[12] = "models/props_trainstation/train002.mdl",
	[13] = "models/props_vehicles/trailer001a.mdl",
	[14] = "models/props_phx/ball.mdl",
	[15] = "models/props_vehicles/car001b_hatchback.mdl",
	[16] = "models/combine_apc.mdl",
	[17] = "models/props_canal/boat002b.mdl",
	[18] = "models/props_combine/combine_train02a.mdl",
	[19] = "models/props_vehicles/car002a_physics.mdl",
	[20] = "models/props_interiors/Furniture_shelf01a.mdl",
	[21] = "models/props_c17/gravestone_coffinpiece001a.mdl",
	[22] = "models/props_c17/gravestone_coffinpiece002a.mdl",
}
PropFall.Votes = {}
PropFall.Round = {} // Round data will be saved in this table
PropFall.Spawns = {}
PropFall.Spawners = {}

// config
PropFall.TimeLeft = 600
PropFall.VoteTime = 60
PropFall.StartDelay = 30
PropFall.Difficulty = { // Spawn Delay in seconds
	["Easy"] = 0.5,	// 2 props/sec
	["Medium"] = 0.25, // 4 props/sec
	["Hard"] = 0.125,	// 8 props/sec
	["Insane"] = 0.0625, // 16 props/sec
}

// enums
PropFall.Waiting = 1
PropFall.Starting = 2
PropFall.Started = 3
PropFall.Finished = 4

local IsValid = IsValid
local reg = debug.getregistry()
local GetPos = reg.Entity.GetPos
local FindByClass = ents.FindByClass
timer.Simple(0, function()
	local Spawners = FindByClass("infodecal")
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

local IsPlayer = reg.Entity.IsPlayer
hook.Add("ShouldCollide", "PropFall.AntiLag", function(ent1, ent2)
	return !(ent1.PropFall != nil and ent2.PropFall != nil)
end)

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

PropFall.Spawner = function(mode)
	timer.Create("PropFall.Spawner", PropFall.Difficulty[mode], -1, function()
		PropFall.Spawn()
	end)
end

local DMG_RADIATION = DMG_RADIATION
local MOVETYPE_NOCLIP = MOVETYPE_NOCLIP
local COLLISION_GROUP_WEAPON = COLLISION_GROUP_WEAPON
PropFall.Start = function()
	PropFall.Round.Status = PropFall.Started
	PropFall.Round.TimeLeft = PropFall.TimeLeft
	timer.Create("PropFall.Timer", 1, -1, function()
		PropFall.Round.TimeLeft = PropFall.Round.TimeLeft - 1
		SetGlobalInt("PropFall.TimeLeft", PropFall.Round.TimeLeft)
		if PropFall.Round.TimeLeft == 0 then
			PropFall.Finish()
		end
	end)
	
	hook.Add("EntityTakeDamage", "PropFall.Finish", function(ply, info)
		if info:GetDamageType() != DMG_RADIATION then return end
		ply:SetMoveType(MOVETYPE_NOCLIP)
		if !ply.finished then
			PropFall.Round.Finishers[#PropFall.Round.Finishers + 1] = ply
			ply.finished = true
			PrintMessage(HUD_PRINTTALK, ply:Nick() .. " has reached the Top")
			if #PropFall.Round.Finishers == 1 then
				PrintMessage(HUD_PRINTCENTER, "you have 1 minute left")
				PropFall.Round.TimeLeft = 60
			end
		end
		return true
	end)

	hook.Add("PlayerSpawn", "PropFall.Spawn", function(ply)
		ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end)

	hook.Add("DoPlayerDeath", "PropFall.Death", function(ply, ent)
		net.Start("PropFall.Death")
			net.WriteEntity(ent)
		net.Send(ply)
	end)
end

PropFall.Finish = function()
	timer.Remove("PropFall.Spawner")
	timer.Remove("PropFall.Timer")
	hook.Remove("DoPlayerDeath", "PropFall.Death")
	hook.Remove("EntityTakeDamage", "PropFall.Finish")
	SetGlobalInt("PropFall.TimeLeft", 0)
	PropFall.Round.Status = PropFall.Finished

	if #PropFall.Round.Finishers > 0 then
		local k = 1
		while !IsValid(PropFall.Round.Finishers[k]) do // if the first entry is invalid then check the next
			k = k + 1
		end
		PrintMessage(HUD_PRINTCENTER, "The Winner is " .. PropFall.Round.Finishers[k]:Nick())
	else
		PrintMessage(HUD_PRINTCENTER, "There is no Winner")
	end

	timer.Simple(5, function()
		for k=1, #PropFall.Round.Finishers do
			PropFall.Round.Finishers[k].finished = nil
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
	hook.Remove("EntityTakeDamage", "PropFall.Finish")
	SetGlobalInt("PropFall.TimeLeft", PropFall.TimeLeft)
	PropFall.Round.Status = PropFall.Starting
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
			end
			hook.Remove("Move", "PropFall.Lobby")
			PropFall.Start()
		end
	end)
end

PropFall.Waiting = function()
	SetGlobalInt("PropFall.Votes.Easy", 0)
	SetGlobalInt("PropFall.Votes.Medium", 0)
	SetGlobalInt("PropFall.Votes.Hard", 0)
	SetGlobalInt("PropFall.Votes.Insane", 0)
	SetGlobalInt("PropFall.VoteTime", 0)
	PropFall.Round = {}
	PropFall.Round.Finishers = {}
	PropFall.Round.Status = PropFall.Waiting

	net.Start("PropFall.Vote")
		net.WriteBool(false)
	net.Broadcast()

	hook.Add("PlayerInitialSpawn", "PropFall.Lobby", function(ply)
		net.Start("PropFall.Vote")
			net.WriteBool(false)
		net.Send(ply)
	end)

	local players = player.GetAll()
	for k=1, #players do
		local ply = players[k]
		ply:SetPos(PropFall.Spawns[math.random(1, #PropFall.Spawns)])
		ply:SetMoveType(MOVETYPE_NONE) 
		ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end

	hook.Add("Move", "PropFall.Lobby", function(ply)
		ply:SetPos(PropFall.Spawns[math.random(1, #PropFall.Spawns)])
		ply:SetMoveType(MOVETYPE_NONE) 
		ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end)
end

hook.Add("Initialize", "PropFall.Initialize", function()
	PropFall.Waiting()
end)

local pairs = pairs
local SetGlobalInt = SetGlobalInt
net.Receive("PropFall.Vote", function(_, ply)
	local vote = net.ReadUInt(3)
	if PropFall.Round.Status != PropFall.Waiting then return end
	PropFall.Votes[ply] = vote

	// recount
	local Easy = 0
	local Medium = 0
	local Hard = 0
	local Insane = 0
	for k, v in pairs(PropFall.Votes) do
		if v == 1 then // Easy
			Easy = Easy + 1
		elseif v == 2 then // Medium
			Medium = Medium + 1
		elseif v == 3 then // Hard
			Hard = Hard + 1
		elseif v == 4 then // Insane
			Insane = Insane + 1
		end
	end
	SetGlobalInt("PropFall.Votes.Easy", Easy)
	SetGlobalInt("PropFall.Votes.Medium", Medium)
	SetGlobalInt("PropFall.Votes.Hard", Hard)
	SetGlobalInt("PropFall.Votes.Insane", Insane)
	PropFall.Round.Easy = Easy
	PropFall.Round.Medium = Medium
	PropFall.Round.Hard = Hard
	PropFall.Round.Insane = Insane

	if Easy > 0 or Medium > 0 or Hard > 0 or Insane > 0 then
		if !timer.Exists("PropFall.Voting") then
			local time = (Easy + Medium + Hard + Insane) == player.GetCount() and 5 or PropFall.VoteTime
			timer.Create("PropFall.Voting", 1, time, function()
				SetGlobalInt("PropFall.VoteTime", time)
				time = time - 1
				if time == 0 then
					local Easy = 0
					local Medium = 0
					local Hard = 0
					local Insane = 0
					for k, v in pairs(PropFall.Votes) do
						if v == 1 then // Easy
							Easy = Easy + 1
						elseif v == 2 then // Medium
							Medium = Medium + 1
						elseif v == 3 then // Hard
							Hard = Hard + 1
						elseif v == 4 then // Insane
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