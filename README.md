# NixOS Config - mae

Ma configuration NixOS avec niri, quickshell et ly.

## Stack

- **OS**: NixOS Unstable
- **Compositor**: niri (Wayland tiling)
- **Bar**: quickshell
- **Display Manager**: ly
- **Shell**: zsh + starship

## Outils de dev

- KiCad (électronique)
- STM32CubeMX + toolchain ARM
- ESP-IDF (ESP32)
- FreeCAD (CAO 3D)

## Installation

### 1. Copier la config hardware

```bash
sudo nixos-generate-config --show-hardware-config > ~/nixos-config/hosts/nixos/hardware-configuration.nix
```

### 2. Appliquer la config

```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#nixos
```

## Mise à jour

```bash
# Mettre à jour les inputs du flake
nix flake update

# Rebuild
sudo nixos-rebuild switch --flake ~/nixos-config#nixos

# Ou utiliser l'alias
update   # rebuild seulement
upgrade  # update flake + rebuild
```

## Structure

```
nixos-config/
├── flake.nix                    # Point d'entrée
├── hosts/nixos/                 # Config machine
│   ├── default.nix
│   └── hardware-configuration.nix
├── modules/
│   ├── desktop/                 # niri, ly, quickshell
│   ├── hardware/                # USB serial (CH340, CP210x)
│   ├── dev/                     # Outils dev
│   └── apps/                    # Applications
└── home/                        # Home-manager
    └── mae.nix
```

## ESP-IDF

ESP-IDF n'est pas installé automatiquement (trop complexe). Pour l'installer:

```bash
mkdir -p ~/esp && cd ~/esp
git clone --recursive https://github.com/espressif/esp-idf.git
cd esp-idf
./install.sh esp32,esp32s3  # Ajoute les targets dont tu as besoin
```

Puis dans chaque session:
```bash
source ~/esp/esp-idf/export.sh
# Ou décommente l'alias dans home/mae.nix et utilise: get_idf
```

## Raccourcis niri

| Raccourci | Action |
|-----------|--------|
| `Mod+Return` | Terminal (foot) |
| `Mod+D` | Launcher (fuzzel) |
| `Mod+Shift+Q` | Fermer fenêtre |
| `Mod+H/J/K/L` | Navigation |
| `Mod+1-5` | Workspaces |
| `Mod+F` | Maximize |
| `Mod+Shift+E` | Quitter niri |
