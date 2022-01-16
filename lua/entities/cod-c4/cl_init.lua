include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local GlowMat = Material("sprites/light_glow02")
-- local GlowMat = Material("particle/particle_glow_01_additive")

function ENT:Draw()

	self:DrawShadow(false)

	-- local R = self:GetColor().r
	-- local G = self:GetColor().g
	-- local B = self:GetColor().b
	-- local A = self:GetColor().a
	-- R = R / 255
	-- G = G / 255
	-- B = B / 255
	-- A = A / 255

	-- local DLight = DynamicLight( self:EntIndex() )
	-- if ( DLight ) then
	-- DLight.Pos = self:GetPos()
	-- DLight.r = R * 12
	-- DLight.g = G * 91
	-- DLight.b = B * 12
	-- DLight.Brightness = A
	-- DLight.Size = 128
	-- DLight.Decay = 512
	-- DLight.DieTime = CurTime() + 1
	-- end

	-- render.SetMaterial( GlowMat )

	-- local Seed1 = self:GetDTFloat( 0 )
	-- local Seed2 = self:GetDTFloat( 1 )
	-- local MyPos = self:GetPos()
	-- local Index = self:EntIndex()

	self.Entity:DrawModel()
end
