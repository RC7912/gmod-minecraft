ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Minecraft Block"
ENT.Author = "dimas"
ENT.Category = "Minecraft"
-- Individual block types are listed in the spawn menu from mc_blocks.lua
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "BlockType" )
	self:NetworkVar( "Bool", 0, "Lit" )
end

function ENT:GetBlock()
	return MC.Get( self:GetBlockType() )
end

-- Must run on both server and client: if the client predicts player movement
-- against different collision than the server, players jitter on top of blocks
function ENT:SetupCollision()
	local h = Vector( MC.HALF, MC.HALF, MC.HALF )
	self:PhysicsInitBox( -h, h )
	self:SetCollisionBounds( -h, h )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:EnableCustomCollisions( true )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:SetMaterial( "concrete" )
		phys:EnableMotion( false )
	end
end
