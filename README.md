# NixOS Config - mae

Ma configuration NixOS avec niri, noctalia-shell et ly.

## Stack

- **OS**: NixOS Unstable
- **Compositor**: niri (Wayland tiling)
- **Bar**: noctalia-shell (Quickshell)
- **Display Manager**: ly
- **Shell**: fish + starship
- **Apps**: Valent (KDE Connect), Discord, GitHub Desktop

## Matériel

- **DisplayLink**: Dell Universal Dock D6000
- **USB Serial**: CH340, CP210x (Arduino/ESP)
- **DNS**: Configuration réseau personnalisée

## Outils de dev

- **Hardware**: KiCad (électronique), FreeCAD (CAO 3D)
- **Embedded**: STM32CubeMX + toolchain ARM, ESP-IDF (ESP32)
- **.NET**: JetBrains Rider

## Installation

### 1. Copier la config hardware

```bash
sudo nixos-generate-config --show-hardware-config > ~/nixos-config/hosts/nixos/hardware-configuration.nix
```

### 2. Télécharger le driver DisplayLink (si hub Dell)

```bash
nix-prefetch-url --name displaylink-620.zip \
  "https://www.synaptics.com/sites/default/files/exe_files/2025-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.2-EXE.zip"
```

### 3. Appliquer la config

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
│   ├── desktop/                 # niri, ly, noctalia-shell
│   ├── hardware/                # DisplayLink, USB serial, DNS
│   ├── dev/                     # KiCad, STM32, ESP-IDF, FreeCAD, Rider
│   └── apps/                    # Discord, GitHub Desktop, Valent
└── home/                        # Home-manager
    ├── mae.nix
    ├── niri/config.kdl
    ├── nvim/
    └── shell/aliases.nix
```

## Notes spécifiques

### ESP-IDF

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

### Valent (KDE Connect)

Installer **KDE Connect** sur ton téléphone (Android/iOS). Valent se connectera automatiquement via le réseau local (ports 1714-1764 ouverts).

### DisplayLink

Le driver DisplayLink nécessite d'accepter l'EULA de Synaptics. Le téléchargement doit être fait manuellement avant le premier rebuild (voir étape 2 de l'installation).

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
