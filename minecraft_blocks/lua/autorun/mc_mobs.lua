-- Minecraft Mobs: model definitions (in Minecraft model pixels) and box-model renderer
AddCSLuaFile()

MC = MC or {}

-- Minecraft model space: y points down, y = 24 is the ground, -z is the front.
-- 1 model pixel = 1/16 block.
MC.PX = 40 / 16
MC.ARROW_GRAVITY = 600

local PI = math.pi

-- box = { x, y, z, w, h, d, u, v, mirror, inflate }
-- hitModel: an invisible stand-in whose single hitbox roughly matches the body; bullets
-- hit nextbots by model hitboxes, so it gets scaled to the mob's height on spawn
MC.Mobs = {
	zombie = {
		name = "Zombie", tex = "zombie/zombie", tw = 64, th = 64,
		hitModel = "models/hunter/tubes/tube1x1x3.mdl",
		hostile = true, attack = "melee", damage = 10, health = 100,
		speed = 70, chaseSpeed = 110, hull = { 24, 78 }, eye = 0.9,
		anim = "humanoid", armsOut = true,
		sounds = { say = { "zombie/say", 3 }, hurt = { "zombie/hurt", 2 }, death = { "zombie/death" }, step = { "zombie/step", 5 } },
		parts = {
			head = { pivot = { 0, 0, 0 }, boxes = { { -4, -8, -4, 8, 8, 8, 0, 0 } } },
			body = { pivot = { 0, 0, 0 }, boxes = { { -4, 0, -2, 8, 12, 4, 16, 16 } } },
			rightArm = { pivot = { -5, 2, 0 }, boxes = { { -3, -2, -2, 4, 12, 4, 40, 16 } } },
			leftArm = { pivot = { 5, 2, 0 }, boxes = { { -1, -2, -2, 4, 12, 4, 40, 16, true } } },
			rightLeg = { pivot = { -1.9, 12, 0 }, boxes = { { -2, 0, -2, 4, 12, 4, 0, 16 } } },
			leftLeg = { pivot = { 1.9, 12, 0 }, boxes = { { -2, 0, -2, 4, 12, 4, 0, 16, true } } },
		},
	},
	skeleton = {
		name = "Skeleton", tex = "skeleton/skeleton", tw = 64, th = 32,
		hitModel = "models/hunter/tubes/tube1x1x3.mdl",
		hostile = true, attack = "ranged", damage = 8, health = 100,
		speed = 70, chaseSpeed = 100, hull = { 24, 78 }, eye = 0.9,
		anim = "humanoid", bow = true,
		sounds = { say = { "skeleton/say", 3 }, hurt = { "skeleton/hurt", 4 }, death = { "skeleton/death" }, step = { "skeleton/step", 4 } },
		parts = {
			head = { pivot = { 0, 0, 0 }, boxes = { { -4, -8, -4, 8, 8, 8, 0, 0 } } },
			body = { pivot = { 0, 0, 0 }, boxes = { { -4, 0, -2, 8, 12, 4, 16, 16 } } },
			rightArm = { pivot = { -5, 2, 0 }, boxes = { { -1, -2, -1, 2, 12, 2, 40, 16 } } },
			leftArm = { pivot = { 5, 2, 0 }, boxes = { { -1, -2, -1, 2, 12, 2, 40, 16, true } } },
			rightLeg = { pivot = { -2, 12, 0 }, boxes = { { -1, 0, -1, 2, 12, 2, 0, 16 } } },
			leftLeg = { pivot = { 2, 12, 0 }, boxes = { { -1, 0, -1, 2, 12, 2, 0, 16, true } } },
		},
	},
	creeper = {
		name = "Creeper", tex = "creeper/creeper", tw = 64, th = 32,
		hitModel = "models/hunter/tubes/tube1x1x3.mdl",
		hostile = true, attack = "explode", damage = 120, health = 100,
		speed = 70, chaseSpeed = 100, hull = { 24, 68 }, eye = 0.85,
		anim = "quadruped",
		sounds = { hurt = { "creeper/say", 4 }, death = { "creeper/death" } },
		parts = {
			head = { pivot = { 0, 6, 0 }, boxes = { { -4, -8, -4, 8, 8, 8, 0, 0 } } },
			body = { pivot = { 0, 6, 0 }, boxes = { { -4, 0, -2, 8, 12, 4, 16, 16 } } },
			leg0 = { pivot = { -2, 18, 4 }, boxes = { { -2, 0, -2, 4, 6, 4, 0, 16 } } },
			leg1 = { pivot = { 2, 18, 4 }, boxes = { { -2, 0, -2, 4, 6, 4, 0, 16 } } },
			leg2 = { pivot = { -2, 18, -4 }, boxes = { { -2, 0, -2, 4, 6, 4, 0, 16 } } },
			leg3 = { pivot = { 2, 18, -4 }, boxes = { { -2, 0, -2, 4, 6, 4, 0, 16 } } },
		},
	},
	spider = {
		name = "Spider", tex = "spider/spider", tw = 64, th = 32,
		hitModel = "models/items/item_item_crate.mdl",
		hostile = true, attack = "melee", damage = 8, health = 80,
		speed = 90, chaseSpeed = 150, hull = { 50, 36 }, eye = 0.7,
		anim = "spider",
		sounds = { say = { "spider/say", 4 }, hurt = { "spider/say", 4 }, death = { "spider/death" }, step = { "spider/step", 4 } },
		parts = {
			head = { pivot = { 0, 15, -3 }, boxes = { { -4, -4, -8, 8, 8, 8, 32, 4 } } },
			neck = { pivot = { 0, 15, 0 }, boxes = { { -3, -3, -3, 6, 6, 6, 0, 0 } } },
			body = { pivot = { 0, 15, 9 }, boxes = { { -5, -4, -6, 10, 8, 12, 0, 12 } } },
			rightHindLeg = { pivot = { -4, 15, 2 }, boxes = { { -15, -1, -1, 16, 2, 2, 18, 0 } } },
			leftHindLeg = { pivot = { 4, 15, 2 }, boxes = { { -1, -1, -1, 16, 2, 2, 18, 0 } } },
			rightMiddleHindLeg = { pivot = { -4, 15, 1 }, boxes = { { -15, -1, -1, 16, 2, 2, 18, 0 } } },
			leftMiddleHindLeg = { pivot = { 4, 15, 1 }, boxes = { { -1, -1, -1, 16, 2, 2, 18, 0 } } },
			rightMiddleFrontLeg = { pivot = { -4, 15, 0 }, boxes = { { -15, -1, -1, 16, 2, 2, 18, 0 } } },
			leftMiddleFrontLeg = { pivot = { 4, 15, 0 }, boxes = { { -1, -1, -1, 16, 2, 2, 18, 0 } } },
			rightFrontLeg = { pivot = { -4, 15, -1 }, boxes = { { -15, -1, -1, 16, 2, 2, 18, 0 } } },
			leftFrontLeg = { pivot = { 4, 15, -1 }, boxes = { { -1, -1, -1, 16, 2, 2, 18, 0 } } },
		},
		-- glowing red eyes
		layers = { { tex = "spider/spider_eyes", fullbright = true, inflate = 0.02, only = { head = true } } },
	},
	pig = {
		name = "Pig", tex = "pig/pig_temperate", tw = 64, th = 64,
		hitModel = "models/hunter/tubes/tube1x1x1.mdl",
		health = 50, speed = 45, panicSpeed = 140, hull = { 36, 36 }, eye = 0.8,
		anim = "quadruped",
		sounds = { say = { "pig/say", 3 }, hurt = { "pig/say", 3 }, death = { "pig/death" }, step = { "pig/step", 5 } },
		parts = {
			head = { pivot = { 0, 12, -6 }, boxes = { { -4, -4, -8, 8, 8, 8, 0, 0 }, { -2, 0, -9, 4, 3, 1, 16, 16 } } },
			body = { pivot = { 0, 11, 2 }, rot = { PI / 2, 0, 0 }, boxes = { { -5, -10, -7, 10, 16, 8, 28, 8 } } },
			leg0 = { pivot = { -3, 18, 7 }, boxes = { { -2, 0, -2, 4, 6, 4, 0, 16 } } },
			leg1 = { pivot = { 3, 18, 7 }, boxes = { { -2, 0, -2, 4, 6, 4, 0, 16 } } },
			leg2 = { pivot = { -3, 18, -5 }, boxes = { { -2, 0, -2, 4, 6, 4, 0, 16 } } },
			leg3 = { pivot = { 3, 18, -5 }, boxes = { { -2, 0, -2, 4, 6, 4, 0, 16 } } },
		},
	},
	sheep = {
		name = "Sheep", tex = "sheep/sheep", tw = 64, th = 32,
		hitModel = "models/hunter/tubes/tube1x1x2.mdl",
		health = 40, speed = 40, panicSpeed = 130, hull = { 36, 52 }, eye = 0.85,
		anim = "quadruped",
		sounds = { say = { "sheep/say", 3 }, hurt = { "sheep/say", 3 }, death = { "sheep/say", 3 }, step = { "sheep/step", 5 } },
		parts = {
			head = { pivot = { 0, 6, -8 }, boxes = { { -3, -4, -6, 6, 6, 8, 0, 0 } } },
			body = { pivot = { 0, 5, 2 }, rot = { PI / 2, 0, 0 }, boxes = { { -4, -10, -7, 8, 16, 6, 28, 8 } } },
			leg0 = { pivot = { -3, 12, 7 }, boxes = { { -2, 0, -2, 4, 12, 4, 0, 16 } } },
			leg1 = { pivot = { 3, 12, 7 }, boxes = { { -2, 0, -2, 4, 12, 4, 0, 16 } } },
			leg2 = { pivot = { -3, 12, -5 }, boxes = { { -2, 0, -2, 4, 12, 4, 0, 16 } } },
			leg3 = { pivot = { 3, 12, -5 }, boxes = { { -2, 0, -2, 4, 12, 4, 0, 16 } } },
		},
		-- fluffy wool coat on top of the shorn body
		layers = { {
			tex = "sheep/sheep_wool",
			parts = {
				head = { { -3, -4, -4, 6, 6, 6, 0, 0, false, 0.6 } },
				body = { { -4, -10, -7, 8, 16, 6, 28, 8, false, 1.75 } },
				leg0 = { { -2, 0, -2, 4, 6, 4, 0, 16, false, 0.5 } },
				leg1 = { { -2, 0, -2, 4, 6, 4, 0, 16, false, 0.5 } },
				leg2 = { { -2, 0, -2, 4, 6, 4, 0, 16, false, 0.5 } },
				leg3 = { { -2, 0, -2, 4, 6, 4, 0, 16, false, 0.5 } },
			},
		} },
	},
	cow = {
		name = "Cow", tex = "cow/cow_temperate", tw = 64, th = 64,
		hitModel = "models/hunter/tubes/tube1x1x2.mdl",
		health = 50, speed = 40, panicSpeed = 130, hull = { 36, 56 }, eye = 0.8,
		anim = "quadruped",
		sounds = { say = { "cow/say", 4 }, hurt = { "cow/hurt", 3 }, death = { "cow/hurt", 3 }, step = { "cow/step", 4 } },
		parts = {
			head = { pivot = { 0, 4, -8 }, boxes = {
				{ -4, -4, -6, 8, 8, 6, 0, 0 },
				{ -5, -5, -4, 1, 3, 1, 22, 0 }, -- horns
				{ 4, -5, -4, 1, 3, 1, 22, 0 },
			} },
			body = { pivot = { 0, 5, 2 }, rot = { PI / 2, 0, 0 }, boxes = {
				{ -6, -10, -7, 12, 18, 10, 18, 4 },
				{ -2, 2, -8, 4, 6, 1, 52, 0 }, -- udder
			} },
			leg0 = { pivot = { -4, 12, 7 }, boxes = { { -2, 0, -2, 4, 12, 4, 0, 16 } } },
			leg1 = { pivot = { 4, 12, 7 }, boxes = { { -2, 0, -2, 4, 12, 4, 0, 16 } } },
			leg2 = { pivot = { -4, 12, -6 }, boxes = { { -2, 0, -2, 4, 12, 4, 0, 16 } } },
			leg3 = { pivot = { 4, 12, -6 }, boxes = { { -2, 0, -2, 4, 12, 4, 0, 16 } } },
		},
	},
	chicken = {
		name = "Chicken", tex = "chicken/chicken_temperate", tw = 64, th = 32,
		hitModel = "models/hunter/tubes/tube1x1x2.mdl",
		health = 20, speed = 35, panicSpeed = 120, hull = { 16, 28 }, eye = 0.85,
		anim = "chicken", slowFall = true,
		sounds = { say = { "chicken/say", 3 }, hurt = { "chicken/hurt", 2 }, death = { "chicken/hurt", 2 }, step = { "chicken/step", 2 } },
		parts = {
			head = { pivot = { 0, 15, -4 }, boxes = {
				{ -2, -6, -2, 4, 6, 3, 0, 0 },
				{ -2, -4, -4, 4, 2, 2, 14, 0 }, -- beak
				{ -1, -2, -3, 2, 2, 2, 14, 4 }, -- wattle
			} },
			body = { pivot = { 0, 16, 0 }, rot = { PI / 2, 0, 0 }, boxes = { { -3, -4, -3, 6, 8, 6, 0, 9 } } },
			rightLeg = { pivot = { -2, 19, 1 }, boxes = { { -1, 0, -3, 3, 5, 3, 26, 0 } } },
			leftLeg = { pivot = { 1, 19, 1 }, boxes = { { -1, 0, -3, 3, 5, 3, 26, 0 } } },
			rightWing = { pivot = { -4, 13, 0 }, boxes = { { 0, 0, -3, 1, 4, 6, 24, 13 } } },
			leftWing = { pivot = { 4, 13, 0 }, boxes = { { -1, 0, -3, 1, 4, 6, 24, 13 } } },
		},
	},
	enderman = {
		name = "Enderman", tex = "enderman/enderman", tw = 64, th = 32,
		hitModel = "models/hunter/tubes/tube1x1x3.mdl",
		hostile = true, neutral = true, attack = "melee", damage = 20, health = 200,
		speed = 70, chaseSpeed = 190, hull = { 24, 112 }, eye = 0.92,
		anim = "enderman", teleports = true, waterHurts = true,
		sounds = { say = { "endermen/idle", 5 }, hurt = { "endermen/hit", 4 }, death = { "endermen/death" }, angry = { "endermen/scream", 4 }, stare = { "endermen/stare" }, teleport = { "endermen/portal" } },
		parts = {
			head = { pivot = { 0, -13, 0 }, boxes = {
				{ -4, -8, -4, 8, 8, 8, 0, 0 },
				{ -4, -9, -4, 8, 8, 8, 0, 16, false, -0.5 }, -- jaw
			} },
			body = { pivot = { 0, -14, 0 }, boxes = { { -4, 0, -2, 8, 12, 4, 32, 16 } } },
			rightArm = { pivot = { -5, -12, 0 }, boxes = { { -1, -2, -1, 2, 30, 2, 56, 0 } } },
			leftArm = { pivot = { 5, -12, 0 }, boxes = { { -1, -2, -1, 2, 30, 2, 56, 0, true } } },
			rightLeg = { pivot = { -2, -6, 0 }, boxes = { { -1, 0, -1, 2, 30, 2, 56, 0 } } },
			leftLeg = { pivot = { 2, -6, 0 }, boxes = { { -1, 0, -1, 2, 30, 2, 56, 0, true } } },
		},
		-- glowing purple eyes
		layers = { { tex = "enderman/enderman_eyes", fullbright = true, inflate = 0.02, only = { head = true } } },
	},
}

-- Slimes: one model drawn at three sizes; killing one splits it into smaller ones
local function slime( size, name, health, damage, splitInto )
	return {
		name = name, tex = "slime/slime", tw = 64, th = 32,
		hitModel = "models/hunter/tubes/tube1x1x1.mdl",
		hostile = true, attack = "slime", damage = damage, health = health,
		speed = 0, chaseSpeed = 0, hopSpeed = 60 + 30 * size, hull = { 20.8 * size, 20.8 * size }, eye = 0.6,
		modelScale = size, anim = "slime", split = splitInto, hidden = size < 4,
		sounds = size > 1
			and { say = { "slime/big", 4 }, hurt = { "slime/big", 4 }, death = { "slime/big", 4 }, hop = { "slime/big", 4 }, attack = { "slime/attack", 2 } }
			or { say = { "slime/small", 5 }, hurt = { "slime/small", 5 }, death = { "slime/small", 5 }, hop = { "slime/small", 5 } },
		parts = {
			cube = { pivot = { 0, 0, 0 }, boxes = {
				{ -3, 17, -3, 6, 6, 6, 0, 16 },
				{ -3.25, 18, -3.5, 2, 2, 2, 32, 0 }, -- eyes
				{ 1.25, 18, -3.5, 2, 2, 2, 32, 4 },
				{ 0, 21, -3.5, 1, 1, 1, 32, 8 }, -- mouth
			} },
		},
		-- see-through jelly around the core
		layers = { { tex = "slime/slime", translucent = true, parts = { cube = { { -4, 16, -4, 8, 8, 8, 0, 0 } } } } },
	}
end
MC.Mobs.slime = slime( 4, "Slime", 80, 15, "slime_medium" )
MC.Mobs.slime_medium = slime( 2, "Medium Slime", 20, 8, "slime_small" )
MC.Mobs.slime_small = slime( 1, "Small Slime", 5, 0 )

-- Spawn menu (NPCs tab)
for id, d in SortedPairs( MC.Mobs ) do
	if d.hidden then continue end
	list.Set( "NPC", "mc_" .. id, {
		Name = d.name,
		Class = "mc_" .. id,
		Category = "Minecraft",
		IconOverride = "minecraft/icons/mc_" .. id .. ".png",
	} )
end

function MC.MobSoundPath( spec )
	if not spec then return end
	local s = "minecraft/mob/" .. spec[ 1 ] .. ( spec[ 2 ] and math.random( spec[ 2 ] ) or "" ) .. ".ogg"
	if file.Exists( "sound/" .. s, "GAME" ) then return s end
end

if SERVER then return end

----------------------------------------------------------------------
-- Renderer
----------------------------------------------------------------------

local cos, sin, abs = math.cos, math.sin, math.abs

-- Box -> 6 textured quads, following Minecraft's ModelBox layout.
-- Each quad: { normal = {x,y,z}, verts = { {x,y,z,u,v} * 4 } } in model pixels.
local function buildBox( b, tw, th, extraInflate )
	local x, y, z, w, h, d, u, v, mirror, inflate = unpack( b, 1, 10 )
	local g = ( inflate or 0 ) + ( extraInflate or 0 )
	local x1, y1, z1, x2, y2, z2 = x - g, y - g, z - g, x + w + g, y + h + g, z + d + g
	if mirror then x1, x2 = x2, x1 end

	local v7 = { x1, y1, z1 }
	local v0 = { x2, y1, z1 }
	local v1 = { x2, y2, z1 }
	local v2 = { x1, y2, z1 }
	local v3 = { x1, y1, z2 }
	local v4 = { x2, y1, z2 }
	local v5 = { x2, y2, z2 }
	local v6 = { x1, y2, z2 }

	local function quad( n, a, bb, c, dd, L, T, R, B )
		-- uv corners: a = (R,T), b = (L,T), c = (L,B), d = (R,B)
		return { n = n, verts = {
			{ a[ 1 ], a[ 2 ], a[ 3 ], R / tw, T / th },
			{ bb[ 1 ], bb[ 2 ], bb[ 3 ], L / tw, T / th },
			{ c[ 1 ], c[ 2 ], c[ 3 ], L / tw, B / th },
			{ dd[ 1 ], dd[ 2 ], dd[ 3 ], R / tw, B / th },
		} }
	end

	local sx = mirror and -1 or 1
	return {
		quad( { sx, 0, 0 }, v4, v0, v1, v5, u + d + w, v + d, u + d + w + d, v + d + h ),
		quad( { -sx, 0, 0 }, v7, v3, v6, v2, u, v + d, u + d, v + d + h ),
		quad( { 0, -1, 0 }, v4, v3, v7, v0, u + d, v, u + d + w, v + d ),
		quad( { 0, 1, 0 }, v1, v2, v6, v5, u + d + w, v + d, u + d + w + w, v ),
		quad( { 0, 0, -1 }, v0, v7, v2, v1, u + d, v + d, u + d + w, v + d + h ),
		quad( { 0, 0, 1 }, v3, v4, v5, v6, u + d + w + d, v + d, u + d + w + d + w, v + d + h ),
	}
end

-- Precompute quads for each layer: { mat, fullbright, parts = { name = quads } }
local function compile( d )
	if d.compiled then return d.compiled end
	local layers = {}
	local function add( tex, tw, th, partBoxes, inflate, fullbright, translucent )
		local L = { tex = tex, fullbright = fullbright, translucent = translucent, parts = {} }
		for name, boxes in pairs( partBoxes ) do
			local quads = {}
			for _, b in ipairs( boxes ) do
				for _, q in ipairs( buildBox( b, tw, th, inflate ) ) do quads[ #quads + 1 ] = q end
			end
			L.parts[ name ] = quads
		end
		layers[ #layers + 1 ] = L
	end

	local base = {}
	for name, p in pairs( d.parts ) do base[ name ] = p.boxes end
	add( d.tex, d.tw, d.th, base )

	for _, layer in ipairs( d.layers or {} ) do
		local boxes = layer.parts
		if not boxes then
			boxes = {}
			for name, p in pairs( d.parts ) do
				if not layer.only or layer.only[ name ] then boxes[ name ] = p.boxes end
			end
		end
		add( layer.tex, layer.tw or d.tw, layer.th or d.th, boxes, layer.inflate, layer.fullbright, layer.translucent )
	end

	d.compiled = layers
	return layers
end

-- rotation matrix R = Rz * Ry * Rx (Minecraft's ModelPart order)
local function rotMatrix( rx, ry, rz )
	local cx, sx, cy, sy, cz, sz = cos( rx ), sin( rx ), cos( ry ), sin( ry ), cos( rz ), sin( rz )
	return {
		cz * cy, cz * sy * sx - sz * cx, cz * sy * cx + sz * sx,
		sz * cy, sz * sy * sx + cz * cx, sz * sy * cx - cz * sx,
		-sy, cy * sx, cy * cx,
	}
end

-- Pose: per-part { rx, ry, rz } added to the part's rest rotation
local ANIM = {}

local function headLook( pose, look )
	pose.head = { look.pitch, look.yaw, 0 }
end

function ANIM.humanoid( d, pose, ls, amt, t, look, ent )
	headLook( pose, look )
	local swing = cos( ls * 0.6662 )
	local sway = cos( t * 1.8 ) * 0.05 + 0.05
	pose.rightArm = { cos( ls * 0.6662 + PI ) * amt, 0, sway }
	pose.leftArm = { swing * amt, 0, -sway }
	pose.rightLeg = { swing * 1.4 * amt, 0, 0 }
	pose.leftLeg = { cos( ls * 0.6662 + PI ) * 1.4 * amt, 0, 0 }

	if ent:GetAggro() then
		if d.armsOut then
			pose.rightArm = { -PI / 2 + sin( t * 3 ) * 0.05, 0, sway }
			pose.leftArm = { -PI / 2 - sin( t * 3 ) * 0.05, 0, -sway }
		elseif d.bow then
			pose.rightArm = { -PI / 2 + look.pitch, -0.1 + look.yaw, 0 }
			pose.leftArm = { -PI / 2 + look.pitch, 0.1 + look.yaw + 0.4, 0 }
		end
	end
end

function ANIM.quadruped( d, pose, ls, amt, t, look )
	headLook( pose, look )
	local a = cos( ls * 0.6662 ) * 1.4 * amt
	local b = cos( ls * 0.6662 + PI ) * 1.4 * amt
	pose.leg0 = { a, 0, 0 }
	pose.leg1 = { b, 0, 0 }
	pose.leg2 = { b, 0, 0 }
	pose.leg3 = { a, 0, 0 }
end

function ANIM.chicken( d, pose, ls, amt, t, look, ent )
	headLook( pose, look )
	pose.rightLeg = { cos( ls * 0.6662 ) * 1.4 * amt, 0, 0 }
	pose.leftLeg = { cos( ls * 0.6662 + PI ) * 1.4 * amt, 0, 0 }
	-- flap while airborne
	local flap = ent.InAir and ( sin( t * 30 ) + 1 ) * 0.8 or 0
	pose.rightWing = { 0, 0, flap }
	pose.leftWing = { 0, 0, -flap }
end

function ANIM.enderman( d, pose, ls, amt, t, look, ent )
	ANIM.humanoid( d, pose, ls, amt, t, look, ent )
	-- long limbs only swing a little
	for _, k in ipairs( { "rightArm", "leftArm", "rightLeg", "leftLeg" } ) do
		pose[ k ][ 1 ] = math.Clamp( pose[ k ][ 1 ] * 0.5, -0.4, 0.4 )
	end
end

function ANIM.slime( d, pose ) end

local SPIDER_REST = {
	rightHindLeg = { -PI / 4, PI / 4 }, leftHindLeg = { PI / 4, -PI / 4 },
	rightMiddleHindLeg = { -0.58119464, PI / 8 }, leftMiddleHindLeg = { 0.58119464, -PI / 8 },
	rightMiddleFrontLeg = { -0.58119464, -PI / 8 }, leftMiddleFrontLeg = { 0.58119464, PI / 8 },
	rightFrontLeg = { -PI / 4, -PI / 4 }, leftFrontLeg = { PI / 4, PI / 4 },
}
local SPIDER_PAIRS = {
	{ "rightHindLeg", "leftHindLeg", 0 },
	{ "rightMiddleHindLeg", "leftMiddleHindLeg", PI },
	{ "rightMiddleFrontLeg", "leftMiddleFrontLeg", PI / 2 },
	{ "rightFrontLeg", "leftFrontLeg", PI * 1.5 },
}

function ANIM.spider( d, pose, ls, amt, t, look )
	headLook( pose, look )
	for _, p in ipairs( SPIDER_PAIRS ) do
		local fy = -( cos( ls * 0.6662 * 2 + p[ 3 ] ) * 0.4 ) * amt
		local fz = abs( sin( ls * 0.6662 + p[ 3 ] ) * 0.4 ) * amt
		local r, l = SPIDER_REST[ p[ 1 ] ], SPIDER_REST[ p[ 2 ] ]
		pose[ p[ 1 ] ] = { 0, r[ 2 ] + fy, r[ 1 ] + fz }
		pose[ p[ 2 ] ] = { 0, l[ 2 ] - fy, l[ 1 ] - fz }
	end
end

-- model pixels -> entity-local Hammer units (forward = -z, left = +x, up = -y, ground at y = 24)
local PX = MC.PX
local function toLocal( x, y, z ) return -z * PX, x * PX, ( 24 - y ) * PX end

-- translucent: draw only the see-through layers (slime jelly) instead of the solid ones
function MC.DrawMob( ent, d, pose, mtx, light, tint, translucent )
	local layers = compile( d )
	cam.PushModelMatrix( mtx )
	for _, L in ipairs( layers ) do
		if ( L.translucent or false ) ~= ( translucent or false ) then continue end
		local mat = MC.LoadMaterial( "minecraft/entity/" .. L.tex .. ".png", L.translucent )
		local k = L.fullbright and 1 or light
		render.SetMaterial( mat )

		for name, quads in pairs( L.parts ) do
			local part = d.parts[ name ]
			local rest = part.rot or { 0, 0, 0 }
			local p = pose[ name ] or { 0, 0, 0 }
			local R = rotMatrix( rest[ 1 ] + p[ 1 ], rest[ 2 ] + p[ 2 ], rest[ 3 ] + p[ 3 ] )
			local px, py, pz = part.pivot[ 1 ], part.pivot[ 2 ], part.pivot[ 3 ]

			mesh.Begin( MATERIAL_QUADS, #quads )
			for _, q in ipairs( quads ) do
				-- face shade from the rotated normal's up component (model -y is up)
				local n = q.n
				local ny = R[ 4 ] * n[ 1 ] + R[ 5 ] * n[ 2 ] + R[ 6 ] * n[ 3 ]
				local s = ( 0.75 - 0.25 * ny ) * k
				local r, g, b = math.min( 255, tint.r * s ), math.min( 255, tint.g * s ), math.min( 255, tint.b * s )
				if L.fullbright then r, g, b = 255, 255, 255 end
				for _, vt in ipairs( q.verts ) do
					local x, y, z = vt[ 1 ], vt[ 2 ], vt[ 3 ]
					local wx = px + R[ 1 ] * x + R[ 2 ] * y + R[ 3 ] * z
					local wy = py + R[ 4 ] * x + R[ 5 ] * y + R[ 6 ] * z
					local wz = pz + R[ 7 ] * x + R[ 8 ] * y + R[ 9 ] * z
					local lx, ly, lz = toLocal( wx, wy, wz )
					mesh.Position( Vector( lx, ly, lz ) )
					mesh.TexCoord( 0, vt[ 4 ], vt[ 5 ] )
					mesh.Color( r, g, b, 255 )
					mesh.AdvanceVertex()
				end
			end
			mesh.End()
		end
	end
	cam.PopModelMatrix()
end

function MC.Animate( ent, d, ls, amt, look )
	local pose = {}
	local f = ANIM[ d.anim ]
	if f then f( d, pose, ls, amt, CurTime(), look, ent ) end
	return pose
end
