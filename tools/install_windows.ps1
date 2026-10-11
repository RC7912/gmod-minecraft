<#
Minecraft Blocks for Garry's Mod - Windows installer

Copies the addon into Garry's Mod and fills in block/mob textures and sounds
from YOUR Minecraft install (Mojang's files can't be redistributed).

Usually you just double-click install_windows.bat. Options:
  -MinecraftDir  path to .minecraft          (default: %APPDATA%\.minecraft)
  -Version       Minecraft version to use     (default: newest installed release)
  -GModDir       path to GarrysMod\garrysmod  (default: found through Steam)
  -AddonDir      install here instead of <GModDir>\addons\minecraft_blocks
#>
param(
    [string]$MinecraftDir = (Join-Path "$env:APPDATA" ".minecraft"),
    [string]$Version,
    [string]$GModDir,
    [string]$AddonDir
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$RepoRoot = Split-Path -Parent $PSScriptRoot
$AddonSrc = Join-Path $RepoRoot "minecraft_blocks"
$Mobs = @("zombie", "skeleton", "creeper", "spider", "pig", "sheep", "cow", "chicken", "endermen", "slime")

# Spawn menu icons: each mob's face, cropped from its texture (x, y, w, h)
$MobFaces = [ordered]@{
    zombie   = @("zombie/zombie", 8, 8, 8, 8)
    skeleton = @("skeleton/skeleton", 8, 8, 8, 8)
    creeper  = @("creeper/creeper", 8, 8, 8, 8)
    spider   = @("spider/spider", 40, 12, 8, 8)
    pig      = @("pig/pig_temperate", 8, 8, 8, 8)
    sheep    = @("sheep/sheep", 8, 8, 6, 6)
    cow      = @("cow/cow_temperate", 6, 6, 8, 8)
    chicken  = @("chicken/chicken_temperate", 3, 3, 4, 6)
    enderman = @("enderman/enderman", 8, 8, 8, 8)
    slime    = @("slime/slime", 6, 22, 6, 6)
}

# Join path parts one segment at a time ("a", "b\c", "d/e"), so it works in
# Windows PowerShell 5.1 (two-argument Join-Path) and on any separator
function P($base) {
    foreach ($part in $args) {
        foreach ($seg in ($part -split '[\\/]')) { if ($seg) { $base = Join-Path $base $seg } }
    }
    return $base
}

function Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Fail($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }

# --- Find Garry's Mod through Steam's library folders ------------------------

function Find-GMod {
    $steamRoots = @()
    foreach ($key in "HKCU:\Software\Valve\Steam", "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam", "HKLM:\SOFTWARE\Valve\Steam") {
        try {
            $p = Get-ItemProperty -Path $key -ErrorAction Stop
            if ($p.SteamPath) { $steamRoots += $p.SteamPath }
            if ($p.InstallPath) { $steamRoots += $p.InstallPath }
        } catch { }
    }
    $steamRoots += "${env:ProgramFiles(x86)}\Steam", "$env:ProgramFiles\Steam"

    $libraries = @()
    foreach ($root in ($steamRoots | Where-Object { $_ } | Select-Object -Unique)) {
        $libraries += $root
        $vdf = P $root "steamapps\libraryfolders.vdf"
        if (Test-Path $vdf) {
            foreach ($m in [regex]::Matches((Get-Content -Raw $vdf), '"path"\s+"([^"]+)"')) {
                $libraries += $m.Groups[1].Value -replace '\\\\', '\'
            }
        }
    }
    foreach ($lib in ($libraries | Select-Object -Unique)) {
        $g = P $lib "steamapps\common\GarrysMod\garrysmod"
        if (Test-Path $g) { return (Resolve-Path $g).Path }
    }
    return $null
}

# --- Pick the Minecraft version ---------------------------------------------

function Pick-Version($mc) {
    $dir = Join-Path $mc "versions"
    if (-not (Test-Path $dir)) { return $null }
    $all = Get-ChildItem $dir -Directory | Where-Object { Test-Path (Join-Path $_.FullName "$($_.Name).jar") }
    $releases = $all | Where-Object { $_.Name -notmatch "snapshot|pre|rc" }
    $pool = if ($releases) { $releases } else { $all }
    if (-not $pool) { return $null }
    return ($pool | Sort-Object LastWriteTime -Descending | Select-Object -First 1).Name
}

# --- Texture and sound lists, read from the addon's own Lua ----------------

function Block-Textures {
    $src = Get-Content -Raw (P $AddonSrc "lua\autorun\mc_blocks.lua")
    $names = @{}
    foreach ($t in [regex]::Matches($src, 'tex = \{([^}]*)\}')) {
        foreach ($n in [regex]::Matches($t.Groups[1].Value, '"([a-z0-9_]+)"')) { $names[$n.Groups[1].Value] = 1 }
    }
    return $names.Keys | Sort-Object
}

function Mob-Textures {
    $src = Get-Content -Raw (P $AddonSrc "lua\autorun\mc_mobs.lua")
    return [regex]::Matches($src, 'tex = "([a-z0-9_/]+)"') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
}

function Base-Sounds {
    $list = @()
    foreach ($k in "stone", "wood", "grass", "gravel", "sand", "snow", "cloth") { 1..4 | ForEach-Object { $list += "dig/$k$_.ogg" } }
    1..3 | ForEach-Object { $list += "random/glass$_.ogg" }
    1..4 | ForEach-Object { $list += "random/explode$_.ogg" }
    $list += "random/fuse.ogg", "random/bow.ogg"
    1..4 | ForEach-Object { $list += "random/bowhit$_.ogg" }
    1..3 | ForEach-Object { $list += "damage/hit$_.ogg" }
    return $list
}

function Write-Entry($zip, $member, $dest) {
    $entry = $zip.GetEntry($member)
    if (-not $entry) { return $false }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
    return $true
}

# --- Main --------------------------------------------------------------------

Write-Host ""
Write-Host "Minecraft Blocks for Garry's Mod - installer" -ForegroundColor Green
Write-Host ""

if (-not (Test-Path $AddonSrc)) { Fail "Can't find the addon folder at $AddonSrc. Run this from inside the downloaded project." }

if (-not $AddonDir) {
    if (-not $GModDir) {
        Step "Looking for Garry's Mod"
        $GModDir = Find-GMod
        if (-not $GModDir) { Fail "Couldn't find Garry's Mod. Re-run with -GModDir ""C:\...\steamapps\common\GarrysMod\garrysmod""." }
    }
    $AddonDir = P $GModDir "addons\minecraft_blocks"
}
Write-Host "    Garry's Mod addon folder: $AddonDir"

if (-not (Test-Path $MinecraftDir)) { Fail "Couldn't find Minecraft at $MinecraftDir. Install Minecraft Java Edition and launch it once, or re-run with -MinecraftDir." }
if (-not $Version) { $Version = Pick-Version $MinecraftDir }
if (-not $Version) { Fail "No Minecraft versions found in $MinecraftDir\versions. Launch Minecraft Java Edition once first." }
$VersionDir = P $MinecraftDir "versions" $Version
Write-Host "    Minecraft $Version from $MinecraftDir"

Step "Copying the addon"
New-Item -ItemType Directory -Force -Path $AddonDir | Out-Null
Copy-Item -Path (Join-Path $AddonSrc "*") -Destination $AddonDir -Recurse -Force

Step "Copying textures from Minecraft"
$zip = [System.IO.Compression.ZipFile]::OpenRead((Join-Path $VersionDir "$Version.jar"))
try {
    $missing = @()
    $blocks = Block-Textures
    foreach ($n in $blocks) {
        if (-not (Write-Entry $zip "assets/minecraft/textures/block/$n.png" (P $AddonDir "materials\minecraft\blocks" "$n.png"))) { $missing += $n }
    }
    Write-Host "    $($blocks.Count - $missing.Count) block textures"
    if ($missing) { Write-Host "    missing (will use flat colors): $($missing -join ', ')" -ForegroundColor Yellow }

    $missing = @()
    $mobTex = Mob-Textures
    foreach ($n in $mobTex) {
        if (-not (Write-Entry $zip "assets/minecraft/textures/entity/$n.png" (P $AddonDir "materials\minecraft\entity" "$n.png"))) { $missing += $n }
    }
    Write-Host "    $($mobTex.Count - $missing.Count) mob textures"
    if ($missing) { Write-Host "    missing: $($missing -join ', ')" -ForegroundColor Yellow }

    # Spawn menu icons need System.Drawing, which only exists on Windows
    try {
        Add-Type -AssemblyName System.Drawing
        $iconDir = P $AddonDir "materials\minecraft\icons"
        New-Item -ItemType Directory -Force -Path $iconDir | Out-Null
        $made = 0
        foreach ($mob in $MobFaces.Keys) {
            $tex, $x, $y, $w, $h = $MobFaces[$mob]
            $entry = $zip.GetEntry("assets/minecraft/textures/entity/$tex.png")
            if (-not $entry) { continue }
            $stream = $entry.Open()
            try {
                $src = New-Object System.Drawing.Bitmap $stream
                $dst = New-Object System.Drawing.Bitmap 128, 128
                $g = [System.Drawing.Graphics]::FromImage($dst)
                $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
                $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
                $g.DrawImage($src, (New-Object System.Drawing.Rectangle 0, 0, 128, 128), (New-Object System.Drawing.Rectangle $x, $y, $w, $h), [System.Drawing.GraphicsUnit]::Pixel)
                $dst.Save((Join-Path $iconDir "mc_$mob.png"), [System.Drawing.Imaging.ImageFormat]::Png)
                $g.Dispose(); $dst.Dispose(); $src.Dispose()
                $made++
            } finally { $stream.Dispose() }
        }
        Write-Host "    $made spawn menu icons"
    } catch {
        Write-Host "    spawn menu icons skipped ($($_.Exception.Message))" -ForegroundColor Yellow
    }
} finally {
    $zip.Dispose()
}

Step "Copying sounds from Minecraft"
$versionJson = Get-Content -Raw (Join-Path $VersionDir "$Version.json") | ConvertFrom-Json
$indexFile = P $MinecraftDir "assets\indexes" "$($versionJson.assetIndex.id).json"
$objects = (Get-Content -Raw $indexFile | ConvertFrom-Json).objects

$wanted = [System.Collections.Generic.List[string]]::new()
foreach ($s in (Base-Sounds)) { $wanted.Add($s) }
# mob sounds: everything directly in sounds/mob/<mob>/ (skips baby/variant subfolders)
foreach ($prop in $objects.PSObject.Properties) {
    $parts = $prop.Name -split '/'
    if ($parts.Count -eq 5 -and $parts[1] -eq "sounds" -and $parts[2] -eq "mob" -and $Mobs -contains $parts[3]) {
        $wanted.Add(($parts[2..4] -join '/'))
    }
}

$copied = 0
foreach ($rel in $wanted) {
    $obj = $objects."minecraft/sounds/$rel"
    if (-not $obj) { continue }
    $h = $obj.hash
    $src = P $MinecraftDir "assets\objects" $h.Substring(0, 2) $h
    if (Test-Path $src) {
        $dest = P $AddonDir "sound\minecraft" $rel
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
        Copy-Item -Force $src $dest
        $copied++
    }
}
Write-Host "    $copied of $($wanted.Count) sounds"

Write-Host ""
Write-Host "Done! Start Garry's Mod (restart it if it's open) and look for:" -ForegroundColor Green
Write-Host "  Spawn menu > Weapons > Minecraft > Minecraft Hand"
Write-Host "  Spawn menu > NPCs > Minecraft"
Write-Host ""
