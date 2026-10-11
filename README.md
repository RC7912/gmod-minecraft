# Minecraft Blocks for Garry's Mod

🇧🇷 **[Versão em português (Brasil) mais abaixo ↓](#pt-br)**

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
- Endermen leave you alone until you look them in the face or hit them. Then they scream, chase you, and teleport around, often away from your shots. Water hurts them: they won't walk into it, and they teleport out if they end up in it.
- Slimes hop at you and split into 2–4 smaller slimes when killed (big → medium → small). The smallest ones are harmless.
- Pigs, sheep, cows and chickens wander around and run away when hurt. Chickens flap and fall slowly.
- They hop up onto single blocks and use the map's navmesh when it has one.
- `ai_disabled 1` freezes them; `ai_ignoreplayers 1` makes hostile mobs leave you alone.

## Notes

- Mojang's textures and sounds aren't redistributable. Don't upload this to the Workshop with `materials/minecraft` or `sound/minecraft` included. Without them the addon falls back to flat colors and HL2 sounds.
- To add a block, add a line to `MC.Blocks` in `lua/autorun/mc_blocks.lua` and run the extractor again.

---

<a id="pt-br"></a>

# Minecraft Blocks para Garry's Mod (Português - Brasil)

Construa com blocos do Minecraft no GMod: blocos que se encaixam numa grade, barra de itens, seletor de blocos, texturas e sons de verdade, e TNT que explode e causa reação em cadeia. Também adiciona dez mobs do Minecraft.

## Instalação

Você precisa do Garry's Mod e do Minecraft Java Edition (aberto pelo menos uma vez). O addon vem sem as texturas e os sons da Mojang; o instalador copia esses arquivos do **seu próprio** Minecraft.

**Downloads:**
- **Windows:** [gmod-minecraft-windows.zip](https://github.com/RC7912/gmod-minecraft/releases/latest/download/gmod-minecraft-windows.zip)
- **Linux / macOS:** [gmod-minecraft-linux-macos.zip](https://github.com/RC7912/gmod-minecraft/releases/latest/download/gmod-minecraft-linux-macos.zip)

### Windows

1. Baixe o **gmod-minecraft-windows.zip** e extraia.
2. Dê dois cliques em `tools\install_windows.bat`.
3. Abra o Garry's Mod (ou reinicie, se já estiver aberto).

O instalador encontra o Garry's Mod pela Steam (inclusive bibliotecas em outros discos), copia o addon para `garrysmod\addons\minecraft_blocks` e pega texturas, sons e ícones do menu de spawn em `%APPDATA%\.minecraft`. Não precisa de Python. Se ele não achar algo sozinho, rode pelo PowerShell informando o caminho:

```
powershell -ExecutionPolicy Bypass -File tools\install_windows.ps1 -GModDir "D:\SteamLibrary\steamapps\common\GarrysMod\garrysmod"
```

Outras opções: `-MinecraftDir`, `-Version` (por padrão usa a versão mais nova instalada). Rode de novo depois de atualizar o Minecraft.

### Linux / macOS

1. Baixe o **gmod-minecraft-linux-macos.zip** e extraia.
2. No terminal, rode:
   ```
   ./tools/install_linux.sh
   ```
3. Abra o Garry's Mod (ou reinicie, se já estiver aberto).

Ele encontra o Garry's Mod em instalações normais, Snap e Flatpak da Steam (e no macOS), copia o addon e pega texturas, sons e ícones do seu Minecraft. Precisa do `python3`; os ícones do menu de spawn também precisam do Pillow (`pip install pillow`), mas o resto funciona sem ele. Opções: `--gmod-dir`, `--addon-dir`, `--mc`, `--version`.

## Como jogar

- Menu de spawn (Q) → Weapons (Armas) → Minecraft → **Minecraft Hand**
  - **Botão esquerdo** quebra, **botão direito** coloca, **rodinha / 1-9** troca o item da barra, **R** abre o seletor de blocos
  - **E** na TNT acende o pavio
- Menu de spawn → Entities (Entidades) → Minecraft tem cada bloco separado.
- Desfaça com Z. `sbox_maxmc_blocks` define o limite por jogador (padrão 3000).

## Mobs

Menu de spawn → NPCs → Minecraft: **Zumbi, Esqueleto, Creeper, Aranha, Enderman, Slime, Porco, Ovelha, Vaca, Galinha**.

- Zumbis e aranhas perseguem e atacam você. Esqueletos mantêm distância e atiram flechas. Creepers chiam, incham e explodem, levando blocos junto.
- Endermen deixam você em paz até você olhar para o rosto deles ou bater neles. Aí eles gritam, perseguem você e se teletransportam, muitas vezes desviando dos seus tiros. Água machuca os Endermen: eles não entram nela e se teletransportam para fora se caírem.
- Slimes pulam em você e, quando morrem, se dividem em 2 a 4 slimes menores (grande → médio → pequeno). Os menores são inofensivos.
- Porcos, ovelhas, vacas e galinhas andam por aí e fogem quando são feridos. Galinhas batem as asas e caem devagar.
- Os mobs sobem em blocos de um de altura e usam o navmesh do mapa quando ele existe.
- `ai_disabled 1` congela os mobs; `ai_ignoreplayers 1` faz os mobs hostis ignorarem você.

## Observações

- As texturas e os sons da Mojang não podem ser redistribuídos. Não envie este addon para a Workshop com `materials/minecraft` ou `sound/minecraft` incluídos. Sem eles, o addon usa cores lisas e sons do HL2.
- Para adicionar um bloco, adicione uma linha em `MC.Blocks` no arquivo `lua/autorun/mc_blocks.lua` e rode o instalador (ou o extrator) de novo.
