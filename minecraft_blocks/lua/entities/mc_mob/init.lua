AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

local SIGHT = 16 * MC.SIZE -- Minecraft's follow range
local CREEPER_FUSE = 1.5
local ARROW_SPEED = 1500

function ENT:Initialize()
	local d = self:GetDef()
	-- scale the stand-in model so its hitbox spans the mob's full height
	self:SetModel( d.hitModel )
	local scale = 1
	local hmins, hmaxs = self:GetHitBoxBounds( 0, 0 )
	if hmins then
		scale = d.hull[ 2 ] / ( hmaxs.z - hmins.z )
		self:SetModelScale( scale, 0 )
	end
	-- the engine multiplies collision bounds by the model scale, and hits outside
	-- them are ignored, so divide it back out to land on the real body size
	local mins, maxs = self:HullBounds()
	self:SetCollisionBounds( mins / scale, maxs / scale )
	self:DrawShadow( false )
	self:SetHealth( d.health )
	self:SetMaxHealth( d.health )

	self.loco:SetStepHeight( 20 )
	self.loco:SetJumpHeight( 56 ) -- clears one block
	self.loco:SetAcceleration( 500 )
	self.loco:SetDeceleration( 900 )
	self.loco:SetDesiredSpeed( d.speed )

	self.NextSay = CurTime() + math.Rand( 2, 8 )
	self.NextStep = 0
	self.NextAttack = 0
	self.NextJump = 0
	self.NextRetarget = 0
end

----------------------------------------------------------------------
-- Sounds
----------------------------------------------------------------------

function ENT:MobSound( kind, level, volume )
	local s = MC.MobSoundPath( self:GetDef().sounds[ kind ] )
	if s then self:EmitSound( s, level or 70, math.random( 85, 115 ), volume or 1 ) end
end

local function hitSound( ent )
	local s = "minecraft/damage/hit" .. math.random( 3 ) .. ".ogg"
	if file.Exists( "sound/" .. s, "GAME" ) then ent:EmitSound( s, 70, math.random( 90, 110 ) ) end
end

----------------------------------------------------------------------
-- Movement
----------------------------------------------------------------------

function ENT:EyePosition()
	return self:GetPos() + Vector( 0, 0, self:GetDef().hull[ 2 ] * self:GetDef().eye )
end

function ENT:CanSee( ent )
	local tr = util.TraceLine( {
		start = self:EyePosition(),
		endpos = ent:EyePos(),
		filter = { self, ent },
		mask = MASK_SOLID,
	} )
	return not tr.Hit
end

local function isWater( pos )
	return bit.band( util.PointContents( pos ), CONTENTS_WATER ) ~= 0
end

function ENT:TouchingWater()
	local pos = self:GetPos()
	return isWater( pos + Vector( 0, 0, 6 ) ) or isWater( pos + Vector( 0, 0, self:GetDef().hull[ 2 ] * 0.5 ) )
end

-- Is there water just ahead, either level with our feet or down a drop we'd walk off?
function ENT:WaterAhead()
	local ahead = self:GetPos() + self:GetForward() * ( self:GetDef().hull[ 1 ] / 2 + 20 ) + Vector( 0, 0, 8 )
	local down = ahead - Vector( 0, 0, 160 )
	local water = util.TraceLine( { start = ahead, endpos = down, mask = MASK_WATER } )
	if not water.Hit then return false end
	if water.StartSolid then return true end
	local ground = util.TraceLine( { start = ahead, endpos = down, mask = MASK_NPCSOLID, filter = self } )
	return not ground.Hit or water.Fraction <= ground.Fraction
end

-- Walk toward pos this tick: follow the navmesh if the map has one, else head straight there
function ENT:GoTo( pos, speed )
	-- endermen refuse to step into water
	if self:GetDef().waterHurts and self:WaterAhead() then
		self:Stop()
		self.WanderGoal = nil
		self.BlockedByWater = true
		return
	end

	self.loco:SetDesiredSpeed( speed )
	self.Moving = true

	if navmesh.IsLoaded() then
		self.Path = self.Path or Path( "Follow" )
		local p = self.Path
		if not p:IsValid() or p:GetAge() > 0.5 or ( self.PathGoal and self.PathGoal:DistToSqr( pos ) > 40 * 40 ) then
			p:SetMinLookAheadDistance( 60 )
			p:SetGoalTolerance( 16 )
			p:Compute( self, pos )
			self.PathGoal = pos
		end
		if p:IsValid() then
			p:Update( self )
			return
		end
	end

	self.loco:Approach( pos, 1 )
	self.loco:FaceTowards( pos )
end

function ENT:Stop()
	self.Moving = false
	self.loco:SetDesiredSpeed( 0 )
end

-- Hop up onto blocks / ledges in the way, like Minecraft mobs do
function ENT:CheckJump()
	if not self.Moving or not self.loco:IsOnGround() or CurTime() < self.NextJump then return end
	local mins, maxs = self:HullBounds()
	local fwd = self:GetForward()
	local pos = self:GetPos()
	local low = util.TraceHull( {
		start = pos + Vector( 0, 0, 4 ), endpos = pos + Vector( 0, 0, 4 ) + fwd * 16,
		mins = Vector( mins.x, mins.y, 0 ), maxs = Vector( maxs.x, maxs.y, 30 ),
		filter = self, mask = MASK_NPCSOLID,
	} )
	if not low.Hit then return end
	local high = util.TraceHull( {
		start = pos + Vector( 0, 0, 46 ), endpos = pos + Vector( 0, 0, 46 ) + fwd * 24,
		mins = Vector( mins.x, mins.y, 0 ), maxs = Vector( maxs.x, maxs.y, maxs.z ),
		filter = self, mask = MASK_NPCSOLID,
	} )
	if high.Hit then return end
	self.loco:Jump()
	self.NextJump = CurTime() + 0.8
end

function ENT:OnStuck()
	if self.loco:IsOnGround() then self.loco:Jump() end
	self.WanderGoal = nil
	self.loco:ClearStuck()
end

function ENT:Wander()
	if self:GetDef().hopSpeed then return self:SlimeBehave() end
	local now = CurTime()
	if self.IdleUntil and now < self.IdleUntil then self:Stop() return end

	if not self.WanderGoal or now > self.WanderUntil or self:GetPos():DistToSqr( self.WanderGoal ) < 30 * 30 then
		if self.WanderGoal and math.random() < 0.6 then
			self.WanderGoal = nil
			self.IdleUntil = now + math.Rand( 2, 6 )
			self:Stop()
			return
		end
		local dir = Angle( 0, math.random( 0, 359 ), 0 ):Forward()
		self.WanderGoal = self:GetPos() + dir * math.Rand( 80, 320 )
		self.WanderUntil = now + 6
	end
	self:GoTo( self.WanderGoal, self:GetDef().speed )
end

----------------------------------------------------------------------
-- Targeting and attacks
----------------------------------------------------------------------

function ENT:ValidTarget( ent )
	-- an angry enderman keeps hunting from as far as it can notice a stare
	local range = ( ent == self.AngryAt ) and 64 * MC.SIZE or SIGHT
	return IsValid( ent ) and ent:IsPlayer() and ent:Alive()
		and ent:GetPos():DistToSqr( self:GetPos() ) < range * range
end

function ENT:FindTarget()
	if GetConVar( "ai_ignoreplayers" ):GetBool() or GetConVar( "ai_disabled" ):GetBool() then return end
	if self:GetDef().neutral then
		-- calm down once whoever angered us is dead or gone
		if not self:ValidTarget( self.AngryAt ) then self.AngryAt = nil end
		return self.AngryAt
	end
	local best, bestDist
	for _, ply in ipairs( player.GetAll() ) do
		if self:ValidTarget( ply ) and self:CanSee( ply ) then
			local dist = ply:GetPos():DistToSqr( self:GetPos() )
			if not best or dist < bestDist then best, bestDist = ply, dist end
		end
	end
	return best
end

function ENT:Attack_melee( target, dist )
	local d = self:GetDef()
	local reach = d.hull[ 1 ] / 2 + 40
	if dist > reach then
		self:GoTo( target:GetPos(), d.chaseSpeed )
		return
	end
	self:Stop()
	self.loco:FaceTowards( target:GetPos() )
	if CurTime() < self.NextAttack then return end
	self.NextAttack = CurTime() + 1

	local dmg = DamageInfo()
	dmg:SetDamage( d.damage )
	dmg:SetAttacker( self )
	dmg:SetInflictor( self )
	dmg:SetDamageType( DMG_SLASH )
	target:TakeDamageInfo( dmg )
	local push = ( target:GetPos() - self:GetPos() ):GetNormalized() * 220
	push.z = 160
	target:SetVelocity( push )
	hitSound( target )
end

function ENT:Attack_ranged( target, dist )
	local d = self:GetDef()
	local visible = self:CanSee( target )
	if dist > 10 * MC.SIZE or not visible then
		self:GoTo( target:GetPos(), d.chaseSpeed )
	elseif dist < 4 * MC.SIZE then
		-- back off a little
		self:GoTo( self:GetPos() + ( self:GetPos() - target:GetPos() ):GetNormalized() * 80, d.speed )
	else
		self:Stop()
	end
	self.loco:FaceTowards( target:GetPos() )

	if visible and CurTime() > self.NextAttack and dist < 15 * MC.SIZE then
		self.NextAttack = CurTime() + math.Rand( 1.5, 2.5 )
		self:ShootArrow( target )
	end
end

function ENT:ShootArrow( target )
	local start = self:EyePosition() - Vector( 0, 0, 6 ) + self:GetForward() * 16
	local aim = target:WorldSpaceCenter() + target:GetVelocity() * 0.15
	local t = start:Distance( aim ) / ARROW_SPEED
	aim.z = aim.z + 0.5 * MC.ARROW_GRAVITY * t * t -- lob to cancel the drop
	local dir = ( aim - start ):GetNormalized() + VectorRand() * 0.02

	local arrow = ents.Create( "mc_arrow" )
	arrow:SetPos( start )
	arrow:SetOwner( self )
	arrow.Velocity = dir:GetNormalized() * ARROW_SPEED
	arrow.Damage = self:GetDef().damage
	arrow:Spawn()

	local s = "minecraft/random/bow.ogg"
	if file.Exists( "sound/" .. s, "GAME" ) then self:EmitSound( s, 70, math.random( 85, 115 ) ) end
end

function ENT:Attack_slime( target, dist )
	self:SlimeBehave( target, dist )
end

-- Slimes never walk: they face their goal and hop toward it
function ENT:SlimeBehave( target, dist )
	local d = self:GetDef()
	local now = CurTime()
	self:Stop()

	local goal
	if IsValid( target ) then
		goal = target:GetPos()
	else
		if not self.WanderGoal or now > self.WanderUntil then
			self.WanderGoal = self:GetPos() + Angle( 0, math.random( 0, 359 ), 0 ):Forward() * math.Rand( 100, 300 )
			self.WanderUntil = now + math.Rand( 3, 6 )
		end
		goal = self.WanderGoal
	end
	self.loco:FaceTowards( goal )

	if self.loco:IsOnGround() and now > ( self.NextHop or 0 ) then
		local dir = goal - self:GetPos()
		dir.z = 0
		dir:Normalize()
		local speed = d.hopSpeed * ( IsValid( target ) and 1.5 or 1 )
		self.loco:Jump()
		self.loco:SetVelocity( dir * speed + Vector( 0, 0, 200 + d.modelScale * 25 ) )
		self.NextHop = now + ( IsValid( target ) and math.Rand( 0.7, 1.3 ) or math.Rand( 1.5, 3.5 ) )
		self:MobSound( "hop", 65 )
	end

	-- big slimes hurt on contact; the smallest ones are harmless
	if IsValid( target ) and d.damage > 0 and now > self.NextAttack and dist < d.hull[ 1 ] / 2 + 30 then
		self.NextAttack = now + 1
		local dmg = DamageInfo()
		dmg:SetDamage( d.damage )
		dmg:SetAttacker( self )
		dmg:SetInflictor( self )
		dmg:SetDamageType( DMG_CRUSH )
		target:TakeDamageInfo( dmg )
		self:MobSound( "attack" )
	end
end

----------------------------------------------------------------------
-- Enderman: anger when stared at, teleporting
----------------------------------------------------------------------

function ENT:Anger( ply )
	if self.AngryAt == ply then return end
	self.AngryAt = ply
	self.Target = ply
	self:MobSound( "angry", 80 )
end

-- Looking an enderman in the face makes it angry, same rule as Minecraft
function ENT:CheckStare()
	local head = self:EyePosition()
	for _, ply in ipairs( player.GetAll() ) do
		if ply:Alive() and ply ~= self.AngryAt then
			local to = head - ply:EyePos()
			local len = to:Length()
			if len < 64 * MC.SIZE then
				local dot = ply:GetAimVector():Dot( to / len )
				if dot > 1 - 0.025 / ( len / MC.SIZE ) and self:CanSee( ply ) then
					self:MobSound( "stare", 80 )
					self:Anger( ply )
					return
				end
			end
		end
	end
end

local function puff( pos, color )
	local fx = EffectData()
	fx:SetOrigin( pos )
	fx:SetStart( color or vector_origin )
	util.Effect( "mc_poof", fx, true, true )
end

-- Hop to a random spot nearby (or near `around`) that has floor and room to stand
function ENT:Teleport( around, radius )
	local mins, maxs = self:HullBounds()
	local center = around or self:GetPos()
	for _ = 1, 24 do
		local try = center + Angle( 0, math.random( 0, 359 ), 0 ):Forward() * math.Rand( radius * 0.4, radius )
		-- search for floor from a few heights, lowest first, so a mob at the bottom of
		-- a deep pool can still reach the shore above it
		local down
		for _, up in ipairs( { 300, radius * 0.5, radius } ) do
			down = util.TraceLine( { start = try + Vector( 0, 0, up ), endpos = try - Vector( 0, 0, 600 ), mask = MASK_NPCSOLID, filter = self } )
			if not down.StartSolid then break end
		end
		if down.Hit and not down.StartSolid and down.HitNormal.z > 0.7 then
			local spot = down.HitPos + Vector( 0, 0, 2 )
			local room = util.TraceHull( { start = spot, endpos = spot, mins = mins, maxs = maxs, mask = MASK_NPCSOLID, filter = self } )
			local wet = self:GetDef().waterHurts and ( isWater( spot + Vector( 0, 0, 8 ) ) or isWater( spot + Vector( 0, 0, maxs.z / 2 ) ) )
			if not room.Hit and not wet then
				puff( self:WorldSpaceCenter(), Vector( 170, 60, 230 ) )
				self:MobSound( "teleport", 75 )
				self:SetPos( spot )
				puff( spot + Vector( 0, 0, maxs.z / 2 ), Vector( 170, 60, 230 ) )
				self.Path = nil
				return true
			end
		end
	end
	return false
end

function ENT:Attack_explode( target, dist )
	local d = self:GetDef()
	local fuse = self:GetFuseStart()

	if fuse == 0 then
		if dist < 3 * MC.SIZE and self:CanSee( target ) then
			self:SetFuseStart( CurTime() )
			self:EmitSound( MC.Sound( "fuse", "weapons/c4/c4_beep1.wav" ) )
			self:Stop()
		else
			self:GoTo( target:GetPos(), d.chaseSpeed )
		end
		return
	end

	self:Stop()
	self.loco:FaceTowards( target:GetPos() )
	if dist > 7 * MC.SIZE then
		self:SetFuseStart( 0 ) -- target got away, calm down
	elseif CurTime() - fuse >= CREEPER_FUSE then
		self.Dead = true
		MC.Explode( self:GetPos() + Vector( 0, 0, 20 ), 3, self, d.damage )
		self:Remove()
	end
end

----------------------------------------------------------------------
-- Brain
----------------------------------------------------------------------

function ENT:Behave()
	local d = self:GetDef()
	local now = CurTime()
	self.Moving = false
	self.BlockedByWater = false

	-- water burns endermen: take damage and teleport somewhere dry
	if d.waterHurts and self:TouchingWater() and now > ( self.NextWaterHurt or 0 ) then
		self.NextWaterHurt = now + 0.5
		local dmg = DamageInfo()
		dmg:SetDamage( 5 )
		dmg:SetAttacker( game.GetWorld() )
		dmg:SetInflictor( game.GetWorld() )
		dmg:SetDamageType( DMG_DROWN )
		self:TakeDamageInfo( dmg )
		if self.Dead then return end
		if self:Teleport( nil, 16 * MC.SIZE ) or self:Teleport( nil, 32 * MC.SIZE ) then return end
	end

	if now > self.NextSay then
		self:MobSound( "say" )
		self.NextSay = now + math.Rand( 6, 14 )
	end

	if d.slowFall and not self.loco:IsOnGround() then
		local v = self.loco:GetVelocity()
		if v.z < -60 then
			v.z = -60
			self.loco:SetVelocity( v )
		end
	end

	if d.neutral and now > ( self.NextStare or 0 ) then
		self.NextStare = now + 0.25
		self:CheckStare()
	end

	-- endermen blink toward a target that got far away, or that's across water
	if d.teleports and IsValid( self.Target ) and now > ( self.NextBlink or 0 ) then
		self.NextBlink = now + math.Rand( 2, 4 )
		if self.WasBlockedByWater or self:GetPos():Distance( self.Target:GetPos() ) > 12 * MC.SIZE then
			self:Teleport( self.Target:GetPos(), 6 * MC.SIZE )
		end
	end

	if d.hostile then
		if now > self.NextRetarget or not self:ValidTarget( self.Target ) then
			self.NextRetarget = now + 1
			if not self:ValidTarget( self.Target ) then self.Target = self:FindTarget() end
		end
		local target = self.Target
		if IsValid( target ) then
			self:SetAggro( true )
			self:SetVictim( target )
			self.IdleUntil = nil
			self[ "Attack_" .. d.attack ]( self, target, self:GetPos():Distance( target:GetPos() ) )
		else
			self:SetAggro( false )
			self:SetVictim( NULL )
			if self:GetFuseStart() ~= 0 then self:SetFuseStart( 0 ) end
			self:Wander()
		end
	elseif self.PanicUntil and now < self.PanicUntil then
		if not self.FleeGoal or now > self.NextFlee then
			local away = self:GetPos() - ( IsValid( self.Attacker ) and self.Attacker:GetPos() or self:GetPos() )
			away.z = 0
			local dir = ( away:GetNormalized() + VectorRand() * 0.6 )
			dir.z = 0
			self.FleeGoal = self:GetPos() + dir:GetNormalized() * 300
			self.NextFlee = now + 1
		end
		self:GoTo( self.FleeGoal, d.panicSpeed )
	else
		self:Wander()
	end

	self:CheckJump()
	self.WasBlockedByWater = self.BlockedByWater

	if self.Moving and self.loco:IsOnGround() and now > self.NextStep and self.loco:GetVelocity():Length2D() > 20 then
		self:MobSound( "step", 60, 0.35 )
		self.NextStep = now + 0.45
	end
end

function ENT:RunBehaviour()
	local aiDisabled = GetConVar( "ai_disabled" )
	while true do
		if aiDisabled:GetBool() then
			self:Stop()
		elseif not self.Dead then
			self:Behave()
		end
		coroutine.yield()
	end
end

----------------------------------------------------------------------
-- Damage
----------------------------------------------------------------------

function ENT:OnInjured( dmg )
	if self.Dead then return end
	self:SetHurtTime( CurTime() )
	self:MobSound( "hurt" )

	local attacker = dmg:GetAttacker()
	self.Attacker = attacker
	local d = self:GetDef()
	if d.hostile then
		if IsValid( attacker ) and attacker:IsPlayer() then
			if d.neutral then self:Anger( attacker ) end
			self.Target = attacker
		end
	else
		self.PanicUntil = CurTime() + 5
		self.FleeGoal = nil
	end

	-- water damage is handled (with its own teleport) in Behave
	if dmg:IsDamageType( DMG_DROWN ) then return end

	if d.teleports and math.random() < 0.5 and self:Teleport( nil, 10 * MC.SIZE ) then return end

	-- knockback
	if IsValid( attacker ) and self.loco:IsOnGround() then
		local push = ( self:GetPos() - attacker:GetPos() ):GetNormalized() * 180
		self.loco:Jump()
		self.loco:SetVelocity( Vector( push.x, push.y, 180 ) )
	end
end

function ENT:OnKilled( dmg )
	if self.Dead then return end
	self.Dead = true
	hook.Run( "OnNPCKilled", self, dmg:GetAttacker(), dmg:GetInflictor() )

	self:SetDeathTime( CurTime() )
	self:SetAggro( false )
	self:SetFuseStart( 0 )
	self:MobSound( "death" )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self.loco:SetDesiredSpeed( 0 )

	-- slimes break into 2-4 smaller slimes
	local split = self:GetDef().split
	if split then
		local w = self:GetDef().hull[ 1 ]
		for i = 1, math.random( 2, 4 ) do
			local child = ents.Create( "mc_" .. split )
			if not IsValid( child ) then break end
			child:SetPos( self:GetPos() + Angle( 0, i * 90 + math.random( -30, 30 ), 0 ):Forward() * w * 0.25 + Vector( 0, 0, 4 ) )
			child:SetAngles( Angle( 0, math.random( 0, 359 ), 0 ) )
			child:Spawn()
		end
	end

	-- tip over, then vanish in a puff of smoke
	timer.Simple( 1, function()
		if not IsValid( self ) then return end
		local fx = EffectData()
		fx:SetOrigin( self:WorldSpaceCenter() )
		util.Effect( "mc_poof", fx, true, true )
		self:Remove()
	end )
end
