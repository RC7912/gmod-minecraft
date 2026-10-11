include( "shared.lua" )

local UP = Vector( 0, 0, 1 )

-- normal, in-plane right/up vectors, texture slot and Minecraft-style face shade
local FACES = {
	{ n = Vector( 0, 0, 1 ), r = Vector( 0, -1, 0 ), u = Vector( 1, 0, 0 ), slot = "top", shade = 1.0 },
	{ n = Vector( 0, 0, -1 ), r = Vector( 0, 1, 0 ), u = Vector( 1, 0, 0 ), slot = "bottom", shade = 0.5 },
	{ n = Vector( 1, 0, 0 ), slot = "front", shade = 0.6 },
	{ n = Vector( -1, 0, 0 ), slot = "front", shade = 0.6 },
	{ n = Vector( 0, 1, 0 ), slot = "side", shade = 0.8 },
	{ n = Vector( 0, -1, 0 ), slot = "side", shade = 0.8 },
}
for _, f in ipairs( FACES ) do
	if not f.r then
		f.r = ( -f.n ):Cross( UP )
		f.u = UP
	end
end

local function faceTexture( tex, slot )
	if slot == "front" then return tex.front or tex.side end
	return tex[ slot ] or tex.side
end

function ENT:Initialize()
	self:SetupCollision()
	local h = Vector( MC.HALF, MC.HALF, MC.HALF )
	self:SetRenderBounds( -h, h )
	self.Light = {}
	self.NextLight = 0
end

-- Sample world lighting per face, cached since blocks don't move
function ENT:UpdateLighting()
	local pos = self:GetPos()
	local glow = self:GetBlock().glow
	for i, f in ipairs( FACES ) do
		if glow then
			self.Light[ i ] = 1
		else
			local l = render.ComputeLighting( pos + f.n * ( MC.HALF + 2 ), f.n )
			local v = math.max( l.x, l.y, l.z )
			self.Light[ i ] = math.Clamp( math.sqrt( v ) * 1.4, 0.3, 1 )
		end
	end
	self.NextLight = CurTime() + 2
end

function ENT:Draw()
	if CurTime() > self.NextLight then self:UpdateLighting() end

	local b = self:GetBlock()
	local pos = self:GetPos()
	local h = MC.HALF

	-- lit TNT flashes white
	local flash = 0
	if self:GetLit() then flash = ( math.sin( CurTime() * 12 ) > 0 ) and 0.6 or 0 end

	for i, f in ipairs( FACES ) do
		local mat, isFallback = MC.GetMaterial( faceTexture( b.tex, f.slot ) )
		local tint = isFallback and b.color or ( f.slot == "top" and b.topTint ) or b.tint
		local k = f.shade * self.Light[ i ]
		local r, g, bl = 255, 255, 255
		if tint then r, g, bl = tint.r, tint.g, tint.b end
		r = Lerp( flash, r * k, 255 )
		g = Lerp( flash, g * k, 255 )
		bl = Lerp( flash, bl * k, 255 )

		local c = pos + f.n * h
		local rh, uh = f.r * h, f.u * h

		render.SetMaterial( mat )
		mesh.Begin( MATERIAL_QUADS, 1 )
			mesh.Position( c - rh + uh ) mesh.TexCoord( 0, 0, 0 ) mesh.Color( r, g, bl, 255 ) mesh.AdvanceVertex()
			mesh.Position( c + rh + uh ) mesh.TexCoord( 0, 1, 0 ) mesh.Color( r, g, bl, 255 ) mesh.AdvanceVertex()
			mesh.Position( c + rh - uh ) mesh.TexCoord( 0, 1, 1 ) mesh.Color( r, g, bl, 255 ) mesh.AdvanceVertex()
			mesh.Position( c - rh - uh ) mesh.TexCoord( 0, 0, 1 ) mesh.Color( r, g, bl, 255 ) mesh.AdvanceVertex()
		mesh.End()
	end
end
