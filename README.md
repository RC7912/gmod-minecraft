# Minecraft Blocks for Garry's Mod

Build with Minecraft blocks in GMod: grid-snapped blocks, a hotbar, a block picker, real textures and sounds, and TNT that blows up and sets off chain reactions. Also adds ten Minecraft mobs.

## Install

You need Garry's Mod and Minecraft Java Edition (launched at least once). The addon ships without Mojang's textures and sounds; the installer copies them from your own Minecraft install.

**Downloads:**
- **Windows:** [gmod-minecraft-windows.zip](https://github.com/RC7912/gmod-minecraft/releases/latest/download/gmod-minecraft-windows.zip)
- **Linux / macOS:** [gmod-minecraft-linux-macos.zip](https://github.com/RC7912/gmod-minecraft/releases/latest/download/gmod-minecraft-linux-macos.zip)

### Windows

1. Download **gmod-minecraft-windows.zip** and unzip it.
2. Double-click `tools\install_windows.bat`.
3. Start Garry's Mod, or restart it if it's already open.

The installer finds Garry's Mod through Steam (including libraries on other drives), copies the addon into `garrysmod\addons\minecraft_blocks`, and fills in textures, sounds and spawn menu icons from `%APPDATA%\.minecraft`. You don't need Python. If something isn't found automatically, run it from PowerShell with a path:

```
powershell -ExecutionPolicy Bypass -File tools\install_windows.ps1 -GModDir "D:\SteamLibrary\steamapps\common\GarrysMod\garrysmod"
```

Other options: `-MinecraftDir`, `-Version` (defaults to the newest installed release). Run it again after a Minecraft update.

### Linux / macOS

1. Download **gmod-minecraft-linux-macos.zip** and unzip it.
2. In a terminal, run:
   ```
   ./tools/install_linux.sh
   ```
3. Start Garry's Mod, or restart it if it's already open.

It finds Garry's Mod in normal, Snap and Flatpak Steam installs (and on macOS), copies the addon and fills in textures, sounds and icons from your Minecraft install. It needs `python3`; spawn menu icons also need Pillow (`pip install pillow`) but everything else works without it. Options: `--gmod-dir`, `--addon-dir`, `--mc`, `--version`.

## Play

- Spawn menu → Weapons → Minecraft → **Minecraft Hand**
  - **LMB** break, **RMB** place, **scroll / 1-9** hotbar, **R** open the block picker
  - **E** on TNT lights it
- Spawn menu → Entities → Minecraft has every block on its own.
- Undo with Z. `sbox_maxmc_blocks` sets the per-player limit (default 3000).

## Mobs

Spawn menu → NPCs → Minecraft: **Zombie, Skeleton, Creeper, Spider, Enderman, Slime, Pig, Sheep, Cow, Chicken**.

- Zombies and spiders chase and hit you. Skeletons keep their distance and shoot arrows. Creepers hiss, swell, then explode, taking blocks with them.
- Endermen leave you alone until you look them in the face or hit them. Then they scream, chase you, and teleport around, often away from your shots.
- Slimes hop at you and split into 2–4 smaller slimes when killed (big → medium → small). The smallest ones are harmless.
- Pigs, sheep, cows and chickens wander around and run away when hurt. Chickens flap and fall slowly.
- They hop up onto single blocks and use the map's navmesh when it has one.
- `ai_disabled 1` freezes them; `ai_ignoreplayers 1` makes hostile mobs leave you alone.

## Notes

- Mojang's textures and sounds aren't redistributable. Don't upload this to the Workshop with `materials/minecraft` or `sound/minecraft` included. Without them the addon falls back to flat colors and HL2 sounds.
- To add a block, add a line to `MC.Blocks` in `lua/autorun/mc_blocks.lua` and run the extractor again.
