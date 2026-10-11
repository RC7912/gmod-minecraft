#!/usr/bin/env bash
# Minecraft Blocks for Garry's Mod - Linux / macOS installer
#
# Copies the addon into Garry's Mod and fills in textures and sounds from
# YOUR Minecraft install (Mojang's files can't be redistributed).
#
# Usage: ./install_linux.sh [--gmod-dir DIR] [--addon-dir DIR] [--mc DIR] [--version V] [--find-only]
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$HERE")"
ADDON_SRC="$ROOT/minecraft_blocks"

GMOD_DIR="" ADDON_DIR="" EXTRA=() FIND_ONLY=0
while [ $# -gt 0 ]; do
	case "$1" in
		--gmod-dir) GMOD_DIR="$2"; shift 2 ;;
		--addon-dir) ADDON_DIR="$2"; shift 2 ;;
		--mc|--version) EXTRA+=("$1" "$2"); shift 2 ;;
		--find-only) FIND_ONLY=1; shift ;;
		-h|--help) sed -n '2,7p' "$0"; exit 0 ;;
		*) echo "Unknown option: $1" >&2; exit 1 ;;
	esac
done

fail() { echo "ERROR: $*" >&2; exit 1; }

# Steam installs: native, Debian/Ubuntu symlink, Snap, Flatpak, macOS
find_gmod() {
	local roots=(
		"$HOME/.steam/steam"
		"$HOME/.local/share/Steam"
		"$HOME/snap/steam/common/.local/share/Steam"
		"$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam"
		"$HOME/Library/Application Support/Steam"
	)
	local libs=() root vdf lib
	for root in "${roots[@]}"; do
		[ -d "$root" ] || continue
		libs+=("$root")
		vdf="$root/steamapps/libraryfolders.vdf"
		if [ -f "$vdf" ]; then
			while IFS= read -r lib; do libs+=("$lib"); done < <(sed -n 's/^[[:space:]]*"path"[[:space:]]*"\(.*\)"[[:space:]]*$/\1/p' "$vdf")
		fi
	done
	for lib in "${libs[@]}"; do
		# macOS keeps the game folder inside an app bundle-style layout
		for g in "$lib/steamapps/common/GarrysMod/garrysmod" "$lib/steamapps/common/GarrysMod/GarrysMod_Signed.app/Contents/MacOS/garrysmod"; do
			if [ -d "$g" ]; then echo "$g"; return 0; fi
		done
	done
	return 1
}

echo
echo "Minecraft Blocks for Garry's Mod - installer"
echo

[ -d "$ADDON_SRC" ] || fail "Can't find the addon folder at $ADDON_SRC. Run this from inside the downloaded project."
command -v python3 >/dev/null || fail "python3 is needed. Install it with your package manager (e.g. sudo apt install python3)."

if [ -z "$ADDON_DIR" ]; then
	if [ -z "$GMOD_DIR" ]; then
		echo "==> Looking for Garry's Mod"
		GMOD_DIR="$(find_gmod)" || fail "Couldn't find Garry's Mod. Re-run with --gmod-dir /path/to/GarrysMod/garrysmod"
	fi
	ADDON_DIR="$GMOD_DIR/addons/minecraft_blocks"
fi
echo "    Garry's Mod addon folder: $ADDON_DIR"
[ "$FIND_ONLY" = 1 ] && exit 0

echo "==> Copying the addon"
mkdir -p "$ADDON_DIR"
cp -R "$ADDON_SRC/." "$ADDON_DIR/"

echo "==> Copying textures and sounds from Minecraft"
python3 "$HERE/extract_minecraft_assets.py" --addon "$ADDON_DIR" ${EXTRA[@]+"${EXTRA[@]}"}

echo
echo "Done! Start Garry's Mod (restart it if it's open) and look for:"
echo "  Spawn menu > Weapons > Minecraft > Minecraft Hand"
echo "  Spawn menu > NPCs > Minecraft"
echo
