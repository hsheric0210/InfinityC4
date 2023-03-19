AddCSLuaFile("shared.lua")

SWEP.Author = "Hoff, kazukazu123123 and eric0210"
SWEP.Instructions = ""

SWEP.Category = "InfinityC4"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/hoff/weapons/seal6_c4/v_c4.mdl"
SWEP.WorldModel = "models/hoff/weapons/seal6_c4/w_c4_0-5.mdl"
SWEP.ViewModelFOV = 70

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "slam"
SWEP.Primary.Delay = .01

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.PrintName = "InfinityC4"
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

hook.Add("Initialize", "createc4convar", function()
	if not ConVarExists("c4_enable") then
		CreateConVar("c4_enable", 1)
	end
	if not ConVarExists("c4_throw_delay") then
		CreateConVar("c4_throw_delay", 0.2)
	end
	if not ConVarExists("c4_explode_delay") then
		CreateConVar("c4_explode_delay", 0.15)
	end
end)

SWEP.Offset = {
	Pos = {
		Up = 0,
		Right = -2,
		Forward = 0,
	},

	Ang = {
		Up = 0,
		Right = 0,
		Forward = -45,
	}
}

function SWEP:DrawWorldModel()
	local hand, offset, rotate

	if not IsValid(self.Owner) then
		self:DrawModel()
		return
	end

	if not self.Hand then
		self.Hand = self.Owner:LookupAttachment("anim_attachment_rh")
	end

	hand = self.Owner:GetAttachment(self.Hand)

	if not hand then
		self:DrawModel()
		return
	end

	offset = hand.Ang:Right() * self.Offset.Pos.Right + hand.Ang:Forward() * self.Offset.Pos.Forward + hand.Ang:Up() * self.Offset.Pos.Up

	hand.Ang:RotateAroundAxis(hand.Ang:Right(), self.Offset.Ang.Right)
	hand.Ang:RotateAroundAxis(hand.Ang:Forward(), self.Offset.Ang.Forward)
	hand.Ang:RotateAroundAxis(hand.Ang:Up(), self.Offset.Ang.Up)

	self:SetRenderOrigin(hand.Pos + offset)
	self:SetRenderAngles(hand.Ang)

	self:DrawModel()
end

function SWEP:Deploy()
	self.Owner.C4s = self.Owner.C4s or {}
	--self:SetModelScale( 0.35, 0 )
end

local reg = debug.getregistry()
local GetVelocity = reg.Entity.GetVelocity
local Length = reg.Vector.Length
--local GetAimVector = reg.Player.GetAimVector
local inRun = false
function SWEP:Think()
	vel = Length(GetVelocity(self.Owner))
	if self.Owner:OnGround() then
		if not inRun and vel > 2.4 and self.Owner:KeyDown(IN_SPEED) then
			self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
			inRun = true
		elseif inRun and not self.Owner:KeyDown(IN_SPEED) then
			self:SendWeaponAnim(ACT_VM_IDLE)
			inRun = false
		end
	end
end

function SWEP:Equip(NewOwner)
	if GetConVar("c4_enable"):GetInt() == 0 then
		CreateConVar("c4_enable", 1)
	end
end

function SWEP:PrimaryAttack()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	CreateConVar("c4_enable", 1)
	timer.Simple(0.1, function()
		if IsValid(self) then
			self:EmitSound("hoff/mpl/seal_c4/c4_click.wav")
		end
	end)
	local delay = GetConVar("c4_explode_delay"):GetFloat()
	if self.Owner:Alive() and self.Owner:IsValid() then
		-- thanks chief tiger
		local Owner = self.Owner
		if SERVER then
			for k, v in pairs(Owner.C4s) do
				timer.Simple(delay * k, function()
					if IsValid(v) then
						v:Explode()
					end
				end)
			end
			Owner.C4s = {} -- Clear the C4 table
		end
	end

	self:SetNextPrimaryFire(CurTime() + 1.1)
	self:SetNextSecondaryFire(CurTime() + GetConVar("c4_throw_delay"):GetFloat())
end

function SWEP:SecondaryAttack()
	if GetConVar("c4_enable"):GetInt() == 0 and GetConVar("c4_enable") ~= nil then
		if (self:Ammo1() <= 0) then
			return false
		end
		self:TakePrimaryAmmo(1)
		CreateConVar("c4_enable", 1)
	end
	self:SendWeaponAnim(ACT_VM_THROW)
	self:EmitSound("hoff/mpl/seal_c4/whoosh_00.wav")
	-- self:TakePrimaryAmmo(1)

	-- local tr = self.Owner:GetEyeTrace()
	if SERVER then
		local ent = ents.Create("cod-c4")

		ent:SetPos(self.Owner:GetShootPos())
		ent:SetAngles(Angle(1, 0, 0))
		ent:Spawn()
		ent.C4Owner = self.Owner

		local phys = ent:GetPhysicsObject()
		phys:SetMass(0.6)
		-- local shot_length = tr.HitPos:Length()
		-- local aimvector = self.Owner:GetAimVector()
		-- phys:ApplyForceCenter (self.Owner:GetAimVector():GetNormalized() * math.pow (shot_length, 3));
		-- phys:ApplyForceCenter(aimvector*500000)
		phys:ApplyForceCenter(self.Owner:GetAimVector() * 1500)
		local angvel = Vector(0, math.random(-5000, -2000), math.random(-100, -900)) -- The positive z coordinate emulates the spin from a right-handed overhand throw
		angvel:Rotate(-1 * ent:EyeAngles())
		angvel:Rotate(Angle(0, self.Owner:EyeAngles().y, 0))
		phys:AddAngleVelocity(angvel)
		--ent:SetVelocity(ent:GetForward()*50000 + ent:GetRight()*50 + ent:GetUp()*50)
		ent:SetGravity(40)
		table.insert(self.Owner.C4s, ent)
	end
	self:SetNextPrimaryFire(CurTime() + 0.1)
	self:SetNextSecondaryFire(CurTime() + GetConVar("c4_throw_delay"):GetFloat())
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:Reload()
	self:SendWeaponAnim(ACT_VM_RELOAD)
	CreateConVar("c4_enable", 1)
end

function SWEP:DrawHUD()
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(Material("models/hoff/weapons/seal6_c4/c4_reticle.png"))
	surface.DrawTexturedRect(ScrW() / 2 - 16, ScrH() / 2 - 16, 32, 32)
end
