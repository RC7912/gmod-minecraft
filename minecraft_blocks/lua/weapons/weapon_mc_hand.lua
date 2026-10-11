AddCSLuaFile()

SWEP.PrintName = "Minecraft Hand"
SWEP.Author = "dimas"
SWEP.Category = "Minecraft"
SWEP.Instructions = "LMB: break  |  RMB: place  |  Scroll / 1-9: hotbar  |  R: pick block  |  E on TNT: light it"
SWEP.Spawnable = true
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

local DELAY = 0.2

function SWEP:Initialize()
	self:SetHoldType( "normal" )
end

function SWEP:GetTrace()
	local ply = self:GetOwner()
	return util.TraceLine( {
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + ply:GetAimVector() * MC.REACH,
		filter = ply,
	} )
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + DELAY )
	if CLIENT then return end

	local tr = self:GetTrace()
	if IsValid( tr.Entity ) and tr.Entity:GetClass() == "mc_block" then
		tr.Entity:Break( self:GetOwner() )
	end
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + DELAY )
	if CLIENT then return end

	local ply = self:GetOwner()
	local tr = self:GetTrace()
	if not tr.Hit or tr.HitSky then return end

	local pos = MC.PlacementPos( tr )

	-- the cell must be empty: no blocks, players, NPCs or world brushes
	local inset = Vector( MC.HALF - 1, MC.HALF - 1, MC.HALF - 1 )
	-- FindInBox uses padded bounds that reach into neighboring cells, so check real overlap
	local mins, maxs = pos - inset, pos + inset
	for _, ent in ipairs( ents.FindInBox( mins, maxs ) ) do
		if ent:GetClass() == "mc_block" then
			if ent:GetPos():DistToSqr( pos ) < MC.HALF * MC.HALF then return end
		elseif ent:IsPlayer() or ent:IsNPC() then
			local p = ent:GetPos()
			local emins, emaxs = p + ent:OBBMins(), p + ent:OBBMaxs()
			if emins.x < maxs.x and emaxs.x > mins.x and emins.y < maxs.y and emaxs.y > mins.y
				and emins.z < maxs.z and emaxs.z > mins.z then return end
		end
	end
	local hull = util.TraceHull( { start = pos, endpos = pos, mins = -inset, maxs = inset, mask = MASK_SOLID_BRUSHONLY } )
	if hull.StartSolid then return end

	if ply.CheckLimit and not ply:CheckLimit( "mc_blocks" ) then return end

	local id = ply.MCBlock or MC.DEFAULT
	local ent = ents.Create( "mc_block" )
	ent:SetPos( pos )
	ent:SetBlockType( id )
	ent:Spawn()
	ent:Activate()
	if ent.CPPISetOwner then ent:CPPISetOwner( ply ) end

	if ply.AddCount then ply:AddCount( "mc_blocks", ent ) end
	if ply.AddCleanup then ply:AddCleanup( "mc_blocks", ent ) end
	undo.Create( "Minecraft Block" )
		undo.AddEntity( ent )
		undo.SetPlayer( ply )
	undo.Finish()

	sound.Play( MC.DigSound( MC.Get( id ).sound ), pos, 70, math.random( 80, 100 ) )
	ply:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:Reload()
	-- handled clientside via PlayerBindPress (Reload isn't called clientside in singleplayer)
end

if SERVER then return end

----------------------------------------------------------------------
-- Client: hotbar, block picker, selection outline
----------------------------------------------------------------------

local hotbarDefault = { "grass_block", "dirt", "stone", "cobblestone", "oak_planks", "oak_log", "glass", "bricks", "tnt" }

MC.Hotbar = MC.Hotbar or {}
for i = 1, 9 do
	local saved = cookie.GetString( "mc_hotbar_" .. i, hotbarDefault[ i ] )
	MC.Hotbar[ i ] = MC.ByID[ saved ] and saved or hotbarDefault[ i ]
end
MC.Slot = MC.Slot or 1

local lastSent
local function sendSelection()
	local id = MC.Hotbar[ MC.Slot ]
	if id == lastSent then return end
	lastSent = id
	net.Start( "mc_select" )
		net.WriteString( id )
	net.SendToServer()
end

local function holding()
	local w = LocalPlayer():GetActiveWeapon()
	return IsValid( w ) and w:GetClass() == "weapon_mc_hand"
end

-- Scroll wheel and number keys move through the hotbar instead of switching weapons
hook.Add( "PlayerBindPress", "MCBlocks_Hotbar", function( ply, bind, pressed )
	if not pressed or not holding() then return end
	if bind == "+reload" then
		MC.OpenPicker()
		return true
	elseif bind == "invnext" then
		MC.Slot = MC.Slot % 9 + 1
	elseif bind == "invprev" then
		MC.Slot = ( MC.Slot - 2 ) % 9 + 1
	else
		local n = tonumber( bind:match( "^slot(%d)$" ) or "" )
		if not n or n < 1 or n > 9 then return end
		MC.Slot = n
	end
	sendSelection()
	return true
end )

local function drawFace( b, x, y, s )
	local icon = MC.GetIcon( b.tex.front or b.tex.side )
	if not icon then
		surface.SetDrawColor( b.color.r, b.color.g, b.color.b, 255 )
		surface.DrawRect( x, y, s, s )
		return
	end
	local tint = b.tint or color_white
	surface.SetMaterial( icon )
	surface.SetDrawColor( tint.r, tint.g, tint.b, 255 )
	surface.DrawTexturedRect( x, y, s, s )
end

function SWEP:DrawHUD()
	sendSelection()

	local s = 44
	local pad = 4
	local w = 9 * ( s + pad ) + pad
	local x0 = ScrW() / 2 - w / 2
	local y0 = ScrH() - s - pad * 2 - 16

	draw.RoundedBox( 4, x0, y0, w, s + pad * 2, Color( 0, 0, 0, 160 ) )
	for i = 1, 9 do
		local x = x0 + pad + ( i - 1 ) * ( s + pad )
		drawFace( MC.Get( MC.Hotbar[ i ] ), x + 4, y0 + pad + 4, s - 8 )
		if i == MC.Slot then
			surface.SetDrawColor( 255, 255, 255 )
			surface.DrawOutlinedRect( x - 2, y0 + pad - 2, s + 4, s + 4, 3 )
		end
	end
	draw.SimpleTextOutlined( MC.Get( MC.Hotbar[ MC.Slot ] ).name, "Trebuchet24", ScrW() / 2, y0 - 8, color_white,
		TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black )
end

-- Black outline on the block you're aiming at, like in Minecraft
hook.Add( "PostDrawOpaqueRenderables", "MCBlocks_Outline", function( depth, sky )
	if depth or sky or not holding() then return end
	local w = LocalPlayer():GetActiveWeapon()
	local tr = w:GetTrace()
	local h = Vector( MC.HALF + 0.3, MC.HALF + 0.3, MC.HALF + 0.3 )
	if IsValid( tr.Entity ) and tr.Entity:GetClass() == "mc_block" then
		render.DrawWireframeBox( tr.Entity:GetPos(), angle_zero, -h, h, color_black, true )
	end
end )

-- Inventory-style picker: click a block to put it in the current hotbar slot
function MC.OpenPicker()
	if IsValid( MC.PickerFrame ) then return end

	local f = vgui.Create( "DFrame" )
	MC.PickerFrame = f
	f:SetTitle( "Pick a block for slot " .. MC.Slot )
	f:SetSize( 560, 420 )
	f:Center()
	f:MakePopup()

	local scroll = f:Add( "DScrollPanel" )
	scroll:Dock( FILL )
	local grid = scroll:Add( "DIconLayout" )
	grid:Dock( FILL )
	grid:SetSpaceX( 6 )
	grid:SetSpaceY( 6 )

	for _, b in ipairs( MC.Blocks ) do
		local btn = grid:Add( "DButton" )
		btn:SetSize( 56, 56 )
		btn:SetText( "" )
		btn:SetTooltip( b.name )
		btn.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, self:IsHovered() and Color( 255, 255, 255, 60 ) or Color( 0, 0, 0, 120 ) )
			drawFace( b, 6, 6, w - 12 )
		end
		btn.DoClick = function()
			MC.Hotbar[ MC.Slot ] = b.id
			cookie.Set( "mc_hotbar_" .. MC.Slot, b.id )
			sendSelection()
			f:Remove()
		end
	end
end
