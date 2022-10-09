-- tables
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
PropFall.Round = {} -- Round data will be saved in this table
PropFall.Spawns = {}
PropFall.Default = {}
PropFall.Spawners = {}

-- default config
PropFall.Default.TimeLeft = 600
PropFall.Default.VoteTime = 60
PropFall.Default.StartDelay = 30
PropFall.Default.WalkSpeed = 200
PropFall.Default.RunSpeed = 400
PropFall.Default.Cheats = false
PropFall.Default.PointDelay = 15
PropFall.Default.Points = 1
PropFall.Default.Difficulty = {
	["Easy"] = 2,
	["Medium"] = 4,
	["Hard"] = 8,
	["Insane"] = 16,
}

-- enums
PropFall.Waiting = 1
PropFall.Starting = 2
PropFall.Started = 3
PropFall.Finished = 4

CreateConVar("propfall_roundtime", PropFall.Default.TimeLeft, FCVAR_ARCHIVE, "PropFall's round time")
CreateConVar("propfall_votetime", PropFall.Default.VoteTime, FCVAR_ARCHIVE, "PropFall's vote time")
CreateConVar("propfall_startdelay", PropFall.Default.StartDelay, FCVAR_ARCHIVE, "PropFall's delay before the Round starts")

CreateConVar("propfall_difficulty.easy", PropFall.Default.Difficulty["Easy"], FCVAR_ARCHIVE, "PropFall's easy difficulty spawn delay")
CreateConVar("propfall_difficulty.medium", PropFall.Default.Difficulty["Medium"], FCVAR_ARCHIVE, "PropFall's medium difficulty spawn delay")
CreateConVar("propfall_difficulty.hard", PropFall.Default.Difficulty["Hard"], FCVAR_ARCHIVE, "PropFall's hard difficulty spawn delay")
CreateConVar("propfall_difficulty.insane", PropFall.Default.Difficulty["Insane"], FCVAR_ARCHIVE, "PropFall's insane difficulty spawn delay")
CreateConVar("propfall_walkspeed", PropFall.Default.WalkSpeed, FCVAR_ARCHIVE, "The walkspeed of all players")
CreateConVar("propfall_runspeed", PropFall.Default.RunSpeed, FCVAR_ARCHIVE, "The walkspeed of all players")
CreateConVar("propfall_allowcheats", PropFall.Default.Cheats and 1 or 0, FCVAR_ARCHIVE, "PropFall's Cheat Toggle")
CreateConVar("propfall_pointdelay", PropFall.Default.PointDelay, FCVAR_ARCHIVE, "The delay to wait before giving everyone a point for the shop")
CreateConVar("propfall_points", PropFall.Default.Points, FCVAR_ARCHIVE, "The amount of points to give")

-- config
PropFall.TimeLeft = GetConVar("propfall_roundtime"):GetInt()
PropFall.VoteTime = GetConVar("propfall_votetime"):GetInt()
PropFall.StartDelay = GetConVar("propfall_startdelay"):GetInt()
PropFall.WalkSpeed = GetConVar("propfall_walkspeed"):GetInt()
PropFall.RunSpeed = GetConVar("propfall_runspeed"):GetInt()
PropFall.Cheats = GetConVar("propfall_allowcheats"):GetBool()
PropFall.PointDelay = GetConVar("propfall_pointdelay"):GetInt()
PropFall.Points = GetConVar("propfall_points"):GetInt()

PropFall.Difficulty = {
	["Easy"] = GetConVar("propfall_difficulty.easy"):GetInt(),
	["Medium"] = GetConVar("propfall_difficulty.medium"):GetInt(),
	["Hard"] = GetConVar("propfall_difficulty.hard"):GetInt(),
	["Insane"] = GetConVar("propfall_difficulty.insane"):GetInt(),
}

cvars.AddChangeCallback("propfall_roundtime", function(_, _, new) PropFall.TimeLeft = new end, "propfall_roundtime")
cvars.AddChangeCallback("propfall_votetime", function(_, _, new) PropFall.VoteTime = new end, "propfall_votetime")
cvars.AddChangeCallback("propfall_startdelay", function(_, _, new) PropFall.StartDelay = new end, "propfall_startdelay")
cvars.AddChangeCallback("propfall_allowcheats", function(_, _, new) PropFall.Cheats = tobool(new) end, "propfall_allowcheats")
cvars.AddChangeCallback("propfall_walkspeed", function(_, _, new) PropFall.WalkSpeed = new end, "propfall_walkspeed")
cvars.AddChangeCallback("propfall_runspeed", function(_, _, new) PropFall.RunSpeed = new end, "propfall_runspeed")
cvars.AddChangeCallback("propfall_pointdelay", function(_, _, new) PropFall.PointDelay = new end, "propfall_pointdelay")
cvars.AddChangeCallback("propfall_points", function(_, _, new) PropFall.Points = new end, "propfall_points")

cvars.AddChangeCallback("propfall_difficulty.easy", function(_, _, new) PropFall.Difficulty["Easy"] = new end, "propfall_difficulty.easy")
cvars.AddChangeCallback("propfall_difficulty.medium", function(_, _, new) PropFall.Difficulty["Medium"] = new end, "propfall_difficulty.medium")
cvars.AddChangeCallback("propfall_difficulty.hard", function(_, _, new) PropFall.Difficulty["Hard"] = new end, "propfall_difficulty.hard")
cvars.AddChangeCallback("propfall_difficulty.insane", function(_, _, new) PropFall.Difficulty["Insane"] = new end, "propfall_difficulty.insane")

concommand.Add("propfall.reset", function()
	GetConVar("propfall_roundtime"):Revert()
	GetConVar("propfall_votetime"):Revert()
	GetConVar("propfall_startdelay"):Revert()
	GetConVar("propfall_difficulty.easy"):Revert()
	GetConVar("propfall_difficulty.medium"):Revert()
	GetConVar("propfall_difficulty.hard"):Revert()
	GetConVar("propfall_difficulty.insane"):Revert()
	GetConVar("propfall_allowcheats"):Revert()
	GetConVar("propfall_walkspeed"):Revert()
	GetConVar("propfall_runspeed"):Revert()
	GetConVar("propfall_pointdelay"):Revert()
	GetConVar("propfall_points"):Revert()
end, nil, "Resets all PropFall Convars", FCVAR_PROTECTED)

GetConVar("sbox_noclip"):SetInt(0)