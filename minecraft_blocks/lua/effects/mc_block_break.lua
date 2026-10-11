-- Little textured cubes popping out of a broken block
function EFFECT:Init( data )
	local b = MC.Blocks[ data:GetMaterialIndex() ] or MC.Get()
	local pos = data:GetOrigin()
	local mat, isFallback = MC.GetMaterial( b.tex.side )
	local tint = isFallback and b.color or b.tint or color_white

	local emitter = ParticleEmitter( pos )
	if not emitter then return end
	for _ = 1, 24 do
		local p = emitter:Add( mat, pos + VectorRand() * MC.HALF * 0.8 )
		if p then
			p:SetVelocity( VectorRand() * 60 + Vector( 0, 0, 60 ) )
			p:SetGravity( Vector( 0, 0, -400 ) )
			p:SetDieTime( math.Rand( 0.4, 0.9 ) )
			p:SetStartSize( math.Rand( 2, 4 ) )
			p:SetEndSize( 0 )
			p:SetStartAlpha( 255 )
			p:SetEndAlpha( 255 )
			p:SetColor( tint.r, tint.g, tint.b )
			p:SetCollide( true )
			p:SetBounce( 0.2 )
		end
	end
	emitter:Finish()
end

function EFFECT:Think() return false end
function EFFECT:Render() end
