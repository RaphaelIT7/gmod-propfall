if !PropFall then return end

if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName = "Stungun"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.Author = "Raphael"
SWEP.Instructions = "Gives the User an Speed boost for 10 Seconds"

SWEP.ViewModel = Model("models/weapons/v_pistol.mdl")
SWEP.WorldModel = Model("models/weapons/w_pistol.mdl")

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Primary.Clipsize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

util.PrecacheSound("Weapon_Pistol.Single")
function SWEP:Initialize()
	self:SetHoldType("pistol")
end

function SWEP:PrimaryAttack()
	if SERVER then
		self:SetNextPrimaryFire(CurTime() + 1)
		self:SetNextSecondaryFire(CurTime() + 1)
		local Owner = self:GetOwner()
		Owner:SetAnimation(PLAYER_ATTACK1)
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

		local tr = util.TraceLine({
			start = Owner:GetShootPos(),
			endpos = Owner:GetShootPos() + Owner:GetAimVector() * 50000,
			filter = Owner
		})
		local Target = tr.Entity
		timer.Simple(self:SequenceDuration() / 2, function()
			if !IsValid(self) then return end
			self:TakePrimaryAmmo(1)
			if IsValid(Target) and Target:IsPlayer() then
				self:EmitSound("propfall/successfull.wav", 75, 100, 0.75)
				Target:SetWalkSpeed(PropFall.WalkSpeed / 2)
				Target:SetRunSpeed(PropFall.RunSpeed / 2)
				timer.Simple(5, function()
					if !IsValid(Target) then return end
					Target:SetWalkSpeed(PropFall.WalkSpeed)
					Target:SetRunSpeed(PropFall.RunSpeed)
				end)
			else
				self:EmitSound("Weapon_Pistol.Single")
			end
			if self:Clip1() == 0 then self:Remove() end
		end)
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end

net.Receive("PropFall.Weapons.StunGun", function()

end)