ENT.Base = "base_nextbot"
ENT.Type = "nextbot"
ENT.PrintName = "Minecraft Mob"
ENT.Author = "dimas"
ENT.Spawnable = false
ENT.MobType = "zombie"

function ENT:SetupDataTables()
	self:NetworkVar( "Float", 0, "HurtTime" )
	self:NetworkVar( "Float", 1, "DeathTime" )
	self:NetworkVar( "Float", 2, "FuseStart" )
	self:NetworkVar( "Bool", 0, "Aggro" )
	self:NetworkVar( "Entity", 0, "Victim" )
end

function ENT:GetDef()
	return MC.Mobs[ self.MobType ]
end

function ENT:HullBounds()
	local w, h = unpack( self:GetDef().hull )
	return Vector( -w / 2, -w / 2, 0 ), Vector( w / 2, w / 2, h )
end
