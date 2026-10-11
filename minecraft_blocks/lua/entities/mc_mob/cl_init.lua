include( "shared.lua" )

ENT.RenderGroup = RENDERGROUP_BOTH

local WHITE = Color( 255, 255, 255 )
local HURT = Color( 255, 110, 110 )

function ENT:Initialize()
	local mins, maxs = self:HullBounds()
	self:SetRenderBounds( mins - Vector( 40, 40, 10 ), maxs + Vector( 40, 40, 30 ) )
	self.LimbSwing = 0
	self.LimbAmount = 0
	self.LastPos = self:GetPos()
	self.Look = { yaw = 0, pitch = 0 }
	self.NextLight = 0
	self.Light = 1
end

-- Walk cycle from how far we actually moved, so it matches the server's movement
function ENT:UpdateAnimation()
	if self.AnimFrame == FrameNumber() then return end
	self.AnimFrame = FrameNumber()

	local dt = FrameTime()
	local pos = self:GetPos()
	local moved = ( pos - self.LastPos ):Length2D()
	local rise = pos.z - self.LastPos.z
	self.LastPos = pos
	if dt > 0 then
		self.VelZ = Lerp( math.min( 1, dt * 10 ), self.VelZ or 0, rise / dt )
		self.InAir = math.abs( self.VelZ ) > 30
	end
	if dt > 0 then
		local target = math.min( 1, moved / dt / 160 )
		self.LimbAmount = Lerp( math.min( 1, dt * 8 ), self.LimbAmount, target )
		self.LimbSwing = self.LimbSwing + self.LimbAmount * dt * 20
	end

	-- head follows the victim, or the local player when they're close
	local d = self:GetDef()
	local who = self:GetVictim()
	if not IsValid( who ) then
		local lp = LocalPlayer()
		if IsValid( lp ) and lp:GetPos():DistToSqr( pos ) < 250 * 250 then who = lp end
	end
	local yaw, pitch = 0, 0
	if IsValid( who ) and self:GetDeathTime() == 0 then
		local eye = pos + Vector( 0, 0, d.hull[ 2 ] * d.eye )
		local aim = ( who:EyePos() - eye ):Angle()
		yaw = math.Clamp( math.NormalizeAngle( aim.y - self:GetAngles().y ), -70, 70 )
		pitch = math.Clamp( math.NormalizeAngle( aim.p ), -40, 40 )
	end
	-- Minecraft model space yaw is clockwise, Source yaw is counter-clockwise
	self.Look.yaw = Lerp( math.min( 1, dt * 10 ), self.Look.yaw, -math.rad( yaw ) )
	self.Look.pitch = Lerp( math.min( 1, dt * 10 ), self.Look.pitch, math.rad( pitch ) )

	if CurTime() > self.NextLight then
		local l = render.ComputeLighting( pos + Vector( 0, 0, 30 ), Vector( 0, 0, 1 ) )
		self.Light = math.Clamp( math.sqrt( math.max( l.x, l.y, l.z ) ) * 1.4, 0.3, 1 )
		self.NextLight = CurTime() + 0.5
	end
end

function ENT:BuildPose()
	self:UpdateAnimation()
	local d = self:GetDef()
	local now = CurTime()

	local mtx = Matrix()
	mtx:Translate( self:GetPos() )
	mtx:Rotate( Angle( 0, self:GetAngles().y, 0 ) )

	local tint = WHITE
	if now - self:GetHurtTime() < 0.4 then tint = HURT end

	-- dying: tip over sideways and go red, like Minecraft
	local died = self:GetDeathTime()
	if died > 0 then
		tint = HURT
		local f = math.min( 1, ( now - died ) / 0.6 )
		mtx:Rotate( Angle( 0, 0, 90 * math.sqrt( f ) ) )
	end

	local s = d.modelScale or 1
	if s ~= 1 then mtx:Scale( Vector( s, s, s ) ) end

	-- slimes stretch going up and squash coming down
	if d.anim == "slime" then
		local k = math.Clamp( ( self.VelZ or 0 ) / 600, -0.3, 0.3 )
		mtx:Scale( Vector( 1 - k * 0.5, 1 - k * 0.5, 1 + k ) )
	end

	-- creeper swelling + white flashes before it blows
	local light = self.Light
	local fuse = self:GetFuseStart()
	if fuse > 0 then
		local f = math.Clamp( ( now - fuse ) / 1.5, 0, 1 )
		local wobble = 1 + math.sin( f * 100 ) * f * 0.01
		local sc = ( 1 + f * f * 0.4 ) * wobble
		mtx:Scale( Vector( sc, sc, ( 1 + f * f * 0.1 ) / wobble ) )
		if math.floor( ( now - fuse ) * 8 ) % 2 == 0 then light = 2.5 end
	end

	return MC.Animate( self, d, self.LimbSwing, self.LimbAmount, self.Look ), mtx, light, tint
end

function ENT:Draw()
	local pose, mtx, light, tint = self:BuildPose()
	self.LastPose = { pose, mtx, light, tint }
	MC.DrawMob( self, self:GetDef(), pose, mtx, light, tint )
end

function ENT:DrawTranslucent()
	if not self:GetDef().layers then return end
	local p = self.LastPose
	if not p then return end
	MC.DrawMob( self, self:GetDef(), p[ 1 ], p[ 2 ], p[ 3 ], p[ 4 ], true )
end
