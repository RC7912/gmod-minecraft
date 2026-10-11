-- Minecraft's death "poof": a burst of grey smoke puffs (or colored, e.g. enderman teleports)
function EFFECT:Init( data )
	local pos = data:GetOrigin()
	-- optional color in Start (endermen use purple)
	local tint = data:GetStart()
	if tint:IsZero() then tint = nil end
	local emitter = ParticleEmitter( pos )
	if not emitter then return end
	for _ = 1, 20 do
		local p = emitter:Add( "particle/particle_smokegrenade", pos + VectorRand() * 16 )
		if p then
			p:SetVelocity( VectorRand() * 40 + Vector( 0, 0, 30 ) )
			p:SetDieTime( math.Rand( 0.5, 1.0 ) )
			p:SetStartSize( math.Rand( 6, 10 ) )
			p:SetEndSize( 2 )
			p:SetStartAlpha( 220 )
			p:SetEndAlpha( 0 )
			if tint then
				p:SetColor( tint.x * math.Rand( 0.7, 1 ), tint.y * math.Rand( 0.7, 1 ), tint.z * math.Rand( 0.7, 1 ) )
			else
				local c = math.random( 180, 240 )
				p:SetColor( c, c, c )
			end
			p:SetAirResistance( 60 )
		end
	end
	emitter:Finish()
end

function EFFECT:Think() return false end
function EFFECT:Render() end
