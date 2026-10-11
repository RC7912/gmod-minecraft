-- Minecraft Blocks: shared definitions
AddCSLuaFile()

MC = MC or {}

-- 1 Minecraft block = 40 Hammer units (a GMod player is 72 units tall, ~1.8 blocks)
MC.SIZE = 40
MC.HALF = MC.SIZE / 2
MC.REACH = 250

-- tex: top / bottom / side, optional front (used on the +x and -x faces)
-- tint: multiplies the texture for grayscale biome-colored textures
-- color: fallback color when the texture hasn't been extracted
MC.Blocks = {
	{ id = "grass_block", name = "Grass Block", tex = { top = "grass_block_top", side = "grass_block_side", bottom = "dirt" }, topTint = Color( 124, 189, 107 ), sound = "grass", color = Color( 95, 159, 53 ) },
	{ id = "dirt", name = "Dirt", tex = { side = "dirt" }, sound = "gravel", color = Color( 134, 96, 67 ) },
	{ id = "stone", name = "Stone", tex = { side = "stone" }, sound = "stone", color = Color( 125, 125, 125 ) },
	{ id = "cobblestone", name = "Cobblestone", tex = { side = "cobblestone" }, sound = "stone", color = Color( 110, 110, 110 ) },
	{ id = "stone_bricks", name = "Stone Bricks", tex = { side = "stone_bricks" }, sound = "stone", color = Color( 122, 121, 122 ) },
	{ id = "mossy_cobblestone", name = "Mossy Cobblestone", tex = { side = "mossy_cobblestone" }, sound = "stone", color = Color( 100, 120, 90 ) },
	{ id = "oak_planks", name = "Oak Planks", tex = { side = "oak_planks" }, sound = "wood", color = Color( 162, 130, 78 ) },
	{ id = "spruce_planks", name = "Spruce Planks", tex = { side = "spruce_planks" }, sound = "wood", color = Color( 114, 84, 48 ) },
	{ id = "oak_log", name = "Oak Log", tex = { top = "oak_log_top", side = "oak_log" }, sound = "wood", color = Color( 109, 85, 50 ) },
	{ id = "birch_log", name = "Birch Log", tex = { top = "birch_log_top", side = "birch_log" }, sound = "wood", color = Color( 216, 215, 210 ) },
	{ id = "oak_leaves", name = "Oak Leaves", tex = { side = "oak_leaves" }, tint = Color( 119, 171, 47 ), sound = "grass", color = Color( 60, 140, 30 ) },
	{ id = "glass", name = "Glass", tex = { side = "glass" }, sound = "glass", color = Color( 200, 230, 240 ) },
	{ id = "sand", name = "Sand", tex = { side = "sand" }, sound = "sand", color = Color( 219, 207, 163 ) },
	{ id = "gravel", name = "Gravel", tex = { side = "gravel" }, sound = "gravel", color = Color( 131, 127, 126 ) },
	{ id = "bricks", name = "Bricks", tex = { side = "bricks" }, sound = "stone", color = Color( 150, 97, 83 ) },
	{ id = "coal_ore", name = "Coal Ore", tex = { side = "coal_ore" }, sound = "stone", color = Color( 105, 105, 105 ) },
	{ id = "iron_ore", name = "Iron Ore", tex = { side = "iron_ore" }, sound = "stone", color = Color( 136, 129, 122 ) },
	{ id = "diamond_ore", name = "Diamond Ore", tex = { side = "diamond_ore" }, sound = "stone", color = Color( 121, 141, 140 ) },
	{ id = "emerald_ore", name = "Emerald Ore", tex = { side = "emerald_ore" }, sound = "stone", color = Color( 117, 136, 124 ) },
	{ id = "iron_block", name = "Block of Iron", tex = { side = "iron_block" }, sound = "stone", color = Color( 220, 220, 220 ) },
	{ id = "gold_block", name = "Block of Gold", tex = { side = "gold_block" }, sound = "stone", color = Color( 246, 208, 61 ) },
	{ id = "obsidian", name = "Obsidian", tex = { side = "obsidian" }, sound = "stone", color = Color( 20, 18, 29 ) },
	{ id = "bedrock", name = "Bedrock", tex = { side = "bedrock" }, sound = "stone", color = Color( 85, 85, 85 ), unbreakable = true },
	{ id = "netherrack", name = "Netherrack", tex = { side = "netherrack" }, sound = "stone", color = Color( 97, 38, 38 ) },
	{ id = "glowstone", name = "Glowstone", tex = { side = "glowstone" }, sound = "glass", color = Color( 171, 131, 84 ), glow = true },
	{ id = "white_wool", name = "White Wool", tex = { side = "white_wool" }, sound = "cloth", color = Color( 234, 236, 237 ) },
	{ id = "snow_block", name = "Snow Block", tex = { side = "snow" }, sound = "snow", color = Color( 249, 254, 254 ) },
	{ id = "bookshelf", name = "Bookshelf", tex = { top = "oak_planks", side = "bookshelf" }, sound = "wood", color = Color( 117, 94, 59 ) },
	{ id = "crafting_table", name = "Crafting Table", tex = { top = "crafting_table_top", bottom = "oak_planks", side = "crafting_table_side", front = "crafting_table_front" }, sound = "wood", color = Color( 120, 73, 42 ) },
	{ id = "pumpkin", name = "Pumpkin", tex = { top = "pumpkin_top", side = "pumpkin_side" }, sound = "wood", color = Color( 198, 118, 24 ) },
	{ id = "melon", name = "Melon", tex = { top = "melon_top", side = "melon_side" }, sound = "wood", color = Color( 111, 145, 30 ) },
	{ id = "tnt", name = "TNT", tex = { top = "tnt_top", bottom = "tnt_bottom", side = "tnt_side" }, sound = "grass", color = Color( 219, 68, 26 ), tnt = true },
}

MC.ByID = {}
for i, b in ipairs( MC.Blocks ) do
	b.index = i
	MC.ByID[ b.id ] = b
end

MC.DEFAULT = "stone"

function MC.Get( id )
	return MC.ByID[ id ] or MC.ByID[ MC.DEFAULT ]
end

-- Center of the grid cell containing pos
function MC.Snap( pos )
	local s = MC.SIZE
	return Vector(
		( math.floor( pos.x / s ) + 0.5 ) * s,
		( math.floor( pos.y / s ) + 0.5 ) * s,
		( math.floor( pos.z / s ) + 0.5 ) * s
	)
end

-- Snap a hit normal to the dominant axis
function MC.AxisNormal( n )
	local ax, ay, az = math.abs( n.x ), math.abs( n.y ), math.abs( n.z )
	if ax >= ay and ax >= az then return Vector( n.x > 0 and 1 or -1, 0, 0 ) end
	if ay >= az then return Vector( 0, n.y > 0 and 1 or -1, 0 ) end
	return Vector( 0, 0, n.z > 0 and 1 or -1 )
end

-- Where a new block goes for a trace: next to the block that was hit, or flush
-- against the world surface (grid-snapped on the other two axes, since map
-- floors and walls rarely line up with the block grid)
function MC.PlacementPos( tr )
	local n = MC.AxisNormal( tr.HitNormal )
	if IsValid( tr.Entity ) and tr.Entity:GetClass() == "mc_block" then
		return tr.Entity:GetPos() + n * MC.SIZE
	end
	local pos = MC.Snap( tr.HitPos + n )
	if n.x ~= 0 then pos.x = tr.HitPos.x + n.x * MC.HALF
	elseif n.y ~= 0 then pos.y = tr.HitPos.y + n.y * MC.HALF
	else pos.z = tr.HitPos.z + n.z * MC.HALF end
	return pos
end

-- Sounds: real Minecraft sounds if extracted, otherwise HL2 fallbacks
local fallback = {
	stone = "physics/concrete/concrete_impact_hard%d.wav",
	wood = "physics/wood/wood_box_impact_hard%d.wav",
	grass = "player/footsteps/grass%d.wav",
	gravel = "player/footsteps/gravel%d.wav",
	sand = "player/footsteps/sand%d.wav",
	snow = "player/footsteps/snow%d.wav",
	cloth = "physics/cardboard/cardboard_box_impact_soft%d.wav",
	glass = "physics/glass/glass_sheet_break%d.wav",
}

function MC.DigSound( kind, breaking )
	if kind == "glass" and breaking then
		local s = "minecraft/random/glass" .. math.random( 3 ) .. ".ogg"
		if file.Exists( "sound/" .. s, "GAME" ) then return s end
	else
		local s = "minecraft/dig/" .. kind .. math.random( 4 ) .. ".ogg"
		if file.Exists( "sound/" .. s, "GAME" ) then return s end
	end
	return string.format( fallback[ kind ] or fallback.stone, math.random( 3 ) )
end

function MC.Sound( name, fb )
	local s = "minecraft/random/" .. name .. ".ogg"
	if file.Exists( "sound/" .. s, "GAME" ) then return s end
	return fb
end

-- Spawn menu entries, one per block type
for _, b in ipairs( MC.Blocks ) do
	list.Set( "SpawnableEntities", "mc_block_" .. b.id, {
		PrintName = b.name,
		ClassName = "mc_block",
		Category = "Minecraft",
		IconOverride = "minecraft/blocks/" .. ( b.tex.front or b.tex.side ) .. ".png",
		KeyValues = { blocktype = b.id },
	} )
end

if SERVER then
	-- TNT and creepers: hurt things and blow up blocks, chaining into other TNT
	function MC.Explode( pos, radiusBlocks, attacker, damage )
		local fx = EffectData()
		fx:SetOrigin( pos )
		util.Effect( "Explosion", fx, true, true )
		sound.Play( MC.Sound( "explode" .. math.random( 4 ), "ambient/explosions/explode_4.wav" ), pos, 100, 100 )

		local radius = radiusBlocks * MC.SIZE
		util.BlastDamage( attacker, attacker, pos, radius, damage )

		for _, ent in ipairs( ents.FindInSphere( pos, radius ) ) do
			if ent:GetClass() == "mc_block" and ent ~= attacker and not ent:GetBlock().unbreakable then
				if ent:GetBlock().tnt then
					-- chain reaction with a short random fuse, like the real thing
					ent:LightFuse( math.Rand( 0.5, 1.5 ) )
				elseif math.random() < 1 - ent:GetPos():Distance( pos ) / radius * 0.7 then
					ent:Remove()
				end
			end
		end
	end

	util.AddNetworkString( "mc_select" )
	CreateConVar( "sbox_maxmc_blocks", "3000", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Max Minecraft blocks per player" )

	net.Receive( "mc_select", function( _, ply )
		local id = net.ReadString()
		if MC.ByID[ id ] then ply.MCBlock = id end
	end )

	hook.Add( "Initialize", "MCBlocks_Cleanup", function()
		if cleanup then cleanup.Register( "mc_blocks" ) end
	end )
else
	language.Add( "Cleanup_mc_blocks", "Minecraft Blocks" )
	language.Add( "Cleaned_mc_blocks", "Cleaned up all Minecraft Blocks" )
	language.Add( "SBoxLimit_mc_blocks", "You've hit the Minecraft block limit!" )
	language.Add( "Undone_Minecraft Block", "Undone Minecraft Block" )

	-- One UnlitGeneric material per texture, point-filtered like the real game
	MC.Materials = {}
	function MC.LoadMaterial( path, translucent )
		local key = translucent and path .. "#t" or path
		local m = MC.Materials[ key ]
		if m then return m, m.isFallback end

		m = CreateMaterial( "mcmat_" .. key:gsub( "[^%w]", "_" ), "UnlitGeneric", {
			[ "$basetexture" ] = "vgui/white",
			[ "$vertexcolor" ] = 1,
			[ "$alphatest" ] = translucent and 0 or 1,
			[ "$alphatestreference" ] = 0.5,
			[ "$translucent" ] = translucent and 1 or 0,
			[ "$nocull" ] = 1,
		} )
		local png = file.Exists( "materials/" .. path, "GAME" ) and Material( path, "noclamp" )
		if png and not png:IsError() then
			m:SetTexture( "$basetexture", png:GetTexture( "$basetexture" ) )
		else
			m.isFallback = true
		end
		MC.Materials[ key ] = m
		return m, m.isFallback
	end

	function MC.GetMaterial( tex )
		return MC.LoadMaterial( "minecraft/blocks/" .. tex .. ".png" )
	end

	-- Plain PNG material for 2D drawing (HUD, picker); nil when not extracted
	MC.Icons = {}
	function MC.GetIcon( tex )
		if MC.Icons[ tex ] == nil then
			local path = "minecraft/blocks/" .. tex .. ".png"
			local m = file.Exists( "materials/" .. path, "GAME" ) and Material( path, "noclamp" )
			MC.Icons[ tex ] = ( m and not m:IsError() ) and m or false
		end
		return MC.Icons[ tex ] or nil
	end
end
