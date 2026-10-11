# Minecraft Blocks for Garry's Mod

Build with Minecraft blocks in GMod: grid-snapped blocks, a hotbar, a block picker, real textures and sounds, and TNT that blows up and sets off chain reactions. Also adds ten Minecraft mobs.

## Install

1. Pull textures and sounds from your own Minecraft install. This has already been run once for 26.3; run it again after a Minecraft update:
   ```
   python3 tools/extract_minecraft_assets.py
   ```
2. Copy (or symlink) `minecraft_blocks/` into `GarrysMod/garrysmod/addons/`
   (Linux: `~/.steam/steam/steamapps/common/GarrysMod/garrysmod/addons/`).

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
