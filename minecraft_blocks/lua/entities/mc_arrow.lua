AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Arrow"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Stuck" )
end

if SERVER then
	function ENT:Initialize()
		self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
		self:DrawShadow( false )
		self.Velocity = self.Velocity or Vector( 0, 0, 0 )
		self.Damage = self.Damage or 8
		self:SetAngles( self.Velocity:Angle() )
		self.LastThink = CurTime()
		SafeRemoveEntityDelayed( self, 15 )
	end

	-- Simple ballistic flight with a swept trace each tick
	function ENT:Think()
		local now = CurTime()
		local dt = now - self.LastThink
		self.LastThink = now
		if self:GetStuck() then return end

		local pos = self:GetPos()
		self.Velocity.z = self.Velocity.z - MC.ARROW_GRAVITY * dt
		local nextPos = pos + self.Velocity * dt
		local tr = util.TraceLine( { start = pos, endpos = nextPos, filter = { self, self:GetOwner() }, mask = MASK_SHOT } )

		if tr.Hit then
			local ent = tr.Entity
			local s = "minecraft/random/bowhit" .. math.random( 4 ) .. ".ogg"
			if file.Exists( "sound/" .. s, "GAME" ) then sound.Play( s, tr.HitPos, 70, math.random( 90, 110 ) ) end

			if IsValid( ent ) and ( ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() ) then
				local dmg = DamageInfo()
				dmg:SetDamage( self.Damage )
				dmg:SetAttacker( IsValid( self:GetOwner() ) and self:GetOwner() or self )
				dmg:SetInflictor( self )
				dmg:SetDamageType( DMG_BULLET )
				dmg:SetDamageForce( self.Velocity:GetNormalized() * 2000 )
				ent:TakeDamageInfo( dmg )
				self:Remove()
				return
			end

			-- stick into walls and blocks
			self:SetPos( tr.HitPos - self.Velocity:GetNormalized() * 6 )
			if IsValid( ent ) then self:SetParent( ent ) end
			self:SetStuck( true )
			SafeRemoveEntityDelayed( self, 10 )
			return
		end

		self:SetPos( nextPos )
		self:SetAngles( self.Velocity:Angle() )
		self:NextThink( now )
		return true
	end
else
	local SHAFT = Color( 110, 80, 50 )
	local TIP = Color( 160, 160, 160 )
	local FLETCH = Color( 230, 230, 230 )

	function ENT:Draw()
		render.SetColorMaterial()
		local pos, ang = self:GetPos(), self:GetAngles()
		render.DrawBox( pos, ang, Vector( -12, -0.6, -0.6 ), Vector( 10, 0.6, 0.6 ), SHAFT )
		render.DrawBox( pos, ang, Vector( 10, -1, -1 ), Vector( 13, 1, 1 ), TIP )
		render.DrawBox( pos, ang, Vector( -13, -2, -0.3 ), Vector( -8, 2, 0.3 ), FLETCH )
		render.DrawBox( pos, ang, Vector( -13, -0.3, -2 ), Vector( -8, 0.3, 2 ), FLETCH )
	end
end
