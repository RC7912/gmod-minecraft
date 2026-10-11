#!/usr/bin/env python3
"""Copy block textures and sounds from YOUR Minecraft install into the GMod addon.

Mojang's assets can't be redistributed, so the addon ships without them and
this script fills them in locally. Don't upload the result to the Workshop.

Usage: python3 extract_minecraft_assets.py [--mc ~/.minecraft] [--version 26.3] [--addon ../minecraft_blocks]
"""
import argparse
import json
import re
import shutil
import sys
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
LUA_DEFS = HERE.parent / "minecraft_blocks" / "lua" / "autorun" / "mc_blocks.lua"
MOB_DEFS = HERE.parent / "minecraft_blocks" / "lua" / "autorun" / "mc_mobs.lua"
MOBS = ("zombie", "skeleton", "creeper", "spider", "pig", "sheep", "cow", "chicken", "endermen", "slime")

# spawn menu icons: the mob's face, cropped from its texture (x, y, w, h)
MOB_FACES = {
    "zombie": ("zombie/zombie", (8, 8, 8, 8)),
    "skeleton": ("skeleton/skeleton", (8, 8, 8, 8)),
    "creeper": ("creeper/creeper", (8, 8, 8, 8)),
    "spider": ("spider/spider", (40, 12, 8, 8)),
    "pig": ("pig/pig_temperate", (8, 8, 8, 8)),
    "sheep": ("sheep/sheep", (8, 8, 6, 6)),
    "cow": ("cow/cow_temperate", (6, 6, 8, 8)),
    "chicken": ("chicken/chicken_temperate", (3, 3, 4, 6)),
    "enderman": ("enderman/enderman", (8, 8, 8, 8)),
    "slime": ("slime/slime", (6, 22, 6, 6)),
}

SOUNDS = (
    [f"dig/{k}{i}.ogg" for k in ("stone", "wood", "grass", "gravel", "sand", "snow", "cloth") for i in range(1, 5)]
    + [f"random/glass{i}.ogg" for i in range(1, 4)]
    + [f"random/explode{i}.ogg" for i in range(1, 5)]
    + ["random/fuse.ogg", "random/bow.ogg"]
    + [f"random/bowhit{i}.ogg" for i in range(1, 5)]
    + [f"damage/hit{i}.ogg" for i in range(1, 4)]
)


def mob_textures():
    return sorted(set(re.findall(r'tex = "([a-z0-9_/]+)"', MOB_DEFS.read_text())))


def make_icons(jar, out):
    try:
        from PIL import Image
    except ImportError:
        print("Icons: skipped (pip install pillow to get mob face icons in the spawn menu)")
        return
    import io
    out.mkdir(parents=True, exist_ok=True)
    for mob, (tex, (x, y, w, h)) in MOB_FACES.items():
        im = Image.open(io.BytesIO(jar.read(f"assets/minecraft/textures/entity/{tex}.png"))).convert("RGBA")
        im.crop((x, y, x + w, y + h)).resize((128, 128), Image.NEAREST).save(out / f"mc_{mob}.png")
    print(f"Icons: {len(MOB_FACES)} made -> {out}")


def textures_from_lua():
    # every texture name referenced in a block's tex = { ... } table
    src = LUA_DEFS.read_text()
    names = set()
    for tex in re.findall(r"tex = \{([^}]*)\}", src):
        names.update(re.findall(r'"([a-z0-9_]+)"', tex))
    return sorted(names)


def default_mc_dir():
    for p in (Path.home() / ".minecraft", Path.home() / "Library/Application Support/minecraft",
              Path.home() / "AppData/Roaming/.minecraft"):
        if p.is_dir():
            return p
    return Path.home() / ".minecraft"


def pick_version(mc: Path):
    # newest installed release (skip snapshots), falling back to anything with a jar
    versions = [v for v in (mc / "versions").iterdir() if (v / f"{v.name}.jar").is_file()]
    releases = [v for v in versions if "snapshot" not in v.name and "pre" not in v.name and "rc" not in v.name]
    pool = releases or versions
    if not pool:
        sys.exit(f"No Minecraft versions with a .jar found in {mc / 'versions'} - launch the game once first.")
    return max(pool, key=lambda v: v.stat().st_mtime).name


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--mc", type=Path, default=default_mc_dir())
    ap.add_argument("--version")
    ap.add_argument("--addon", type=Path, default=HERE.parent / "minecraft_blocks")
    args = ap.parse_args()

    version = args.version or pick_version(args.mc)
    vdir = args.mc / "versions" / version
    print(f"Using Minecraft {version} from {args.mc}")

    tex_out = args.addon / "materials" / "minecraft" / "blocks"
    tex_out.mkdir(parents=True, exist_ok=True)
    missing = []
    with zipfile.ZipFile(vdir / f"{version}.jar") as jar:
        for name in textures_from_lua():
            member = f"assets/minecraft/textures/block/{name}.png"
            try:
                (tex_out / f"{name}.png").write_bytes(jar.read(member))
            except KeyError:
                missing.append(name)
        ent_out = args.addon / "materials" / "minecraft" / "entity"
        ent_missing = []
        for name in mob_textures():
            try:
                data = jar.read(f"assets/minecraft/textures/entity/{name}.png")
            except KeyError:
                ent_missing.append(name)
                continue
            (ent_out / name).parent.mkdir(parents=True, exist_ok=True)
            (ent_out / f"{name}.png").write_bytes(data)
        make_icons(jar, args.addon / "materials" / "minecraft" / "icons")
    print(f"Textures: {len(textures_from_lua()) - len(missing)} blocks -> {tex_out}")
    if missing:
        print("  missing (will use flat colors):", ", ".join(missing))
    print(f"Textures: {len(mob_textures()) - len(ent_missing)} mobs -> {ent_out}")
    if ent_missing:
        print("  missing:", ", ".join(ent_missing))

    index_id = json.loads((vdir / f"{version}.json").read_text())["assetIndex"]["id"]
    objects = json.loads((args.mc / "assets" / "indexes" / f"{index_id}.json").read_text())["objects"]
    snd_out = args.addon / "sound" / "minecraft"
    # mob sounds: everything directly in sounds/mob/<mob>/ (skips baby/variant subfolders)
    mob_sounds = [k[len("minecraft/sounds/"):] for k in objects
                  if any(k.startswith(f"minecraft/sounds/mob/{m}/") and k.count("/") == 4 for m in MOBS)]
    copied = 0
    for rel in SOUNDS + sorted(mob_sounds):
        obj = objects.get(f"minecraft/sounds/{rel}")
        if not obj:
            continue
        h = obj["hash"]
        src = args.mc / "assets" / "objects" / h[:2] / h
        if src.is_file():
            dst = snd_out / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(src, dst)
            copied += 1
    print(f"Sounds: {copied}/{len(SOUNDS) + len(mob_sounds)} copied -> {snd_out}")


if __name__ == "__main__":
    main()
