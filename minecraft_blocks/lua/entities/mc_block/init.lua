AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

local FUSE_TIME = 4
local BLAST_RADIUS = 4 -- in blocks

function ENT:KeyValue( key, value )
	if key == "blocktype" then self.PendingType = value end
end

function ENT:Initialize()
	if self:GetBlockType() == "" then
		self:SetBlockType( MC.ByID[ self.PendingType or "" ] and self.PendingType or MC.DEFAULT )
	end

	self:SetModel( "models/hunter/blocks/cube1x1x1.mdl" )
	self:SetAngles( angle_zero )

	-- spawned from the spawn menu: settle onto whatever is below
	if self.PendingType then
		local tr = util.TraceLine( { start = self:GetPos(), endpos = self:GetPos() - Vector( 0, 0, 128 ), filter = self } )
		self:SetPos( tr.Hit and MC.PlacementPos( tr ) or MC.Snap( self:GetPos() ) )
	end

	self:SetupCollision()
	self:DrawShadow( false )
	self:SetUseType( SIMPLE_USE )
end

-- Keep blocks on the grid: no physgun dragging
hook.Add( "PhysgunPickup", "MCBlocks_NoPhysgun", function( _, ent )
	if IsValid( ent ) and ent:GetClass() == "mc_block" then return false end
end )

function ENT:Break( ply )
	local b = self:GetBlock()
	if b.unbreakable and not ( IsValid( ply ) and ply:IsAdmin() ) then return false end
	sound.Play( MC.DigSound( b.sound, true ), self:GetPos(), 75, math.random( 80, 100 ) )

	local fx = EffectData()
	fx:SetOrigin( self:GetPos() )
	fx:SetMaterialIndex( b.index )
	util.Effect( "mc_block_break", fx, true, true )

	self:Remove()
	return true
end

-- Press E on TNT to light it
function ENT:Use( activator )
	if self:GetBlock().tnt then self:LightFuse( FUSE_TIME ) end
end

function ENT:LightFuse( fuse )
	if self:GetLit() then return end
	self:SetLit( true )
	self:EmitSound( MC.Sound( "fuse", "weapons/c4/c4_beep1.wav" ) )
	timer.Simple( fuse, function()
		if IsValid( self ) then self:Explode() end
	end )
end

function ENT:Explode()
	MC.Explode( self:GetPos(), BLAST_RADIUS, self, 80 )
	self:Remove()
end
