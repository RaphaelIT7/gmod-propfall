if !PropFall then return end

if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName = "Adrenaline"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Author = "Raphael"
SWEP.Instructions = "Gives the User an Speed boost for 10 Seconds"

SWEP.ViewModel = Model("models/weapons/c_medkit.mdl")
SWEP.WorldModel = Model("models/weapons/w_medkit.mdl")

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Primary.Clipsize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.UseHands = true

util.PrecacheSound("propfall/successfull.wav")
function SWEP:Initialize()
	self:SetHoldType("slam")
end

function SWEP:PrimaryAttack()
	if SERVER then
		self:SetNextPrimaryFire(CurTime() + 5)
		self:SetNextSecondaryFire(CurTime() + 5)

		local Owner = self:GetOwner()
		Owner:SetAnimation(PLAYER_ATTACK1)
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		timer.Simple(self:SequenceDuration() / 3, function()
			if !IsValid(self) then return end
			self:EmitSound("propfall/successfull.wav", 75, 100, 0.75)
			self:Remove()
			Owner:SetWalkSpeed(PropFall.WalkSpeed * 1.5)
			Owner:SetRunSpeed(PropFall.RunSpeed * 1.5)
			timer.Simple(10, function()
				if !IsValid(Owner) then return end
				Owner:SetWalkSpeed(PropFall.WalkSpeed)
				Owner:SetRunSpeed(PropFall.RunSpeed)
			end)
		end)
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end