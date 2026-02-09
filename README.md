# NixOS Config - mae

Ma configuration NixOS avec Hyprland/Sway, waybar et SDDM.

## Stack

- **OS**: NixOS Unstable
- **Compositeurs**: Hyprland (recommandé) / Sway (i3-compatible)
- **Bar**: waybar
- **Display Manager**: SDDM (thème Catppuccin Mocha)
- **Shell**: zsh (défaut) / fish + starship
- **File Manager**: Dolphin (KDE) avec support SMB, archives, thumbnails
- **Apps**: Discord, GitHub Desktop, Valent (KDE Connect)

## Matériel

- **DisplayLink**: Dell Universal Dock D6000 (driver évdi)
- **USB Serial**: CH340, CP210x (Arduino/ESP)
- **Multi-écrans**: DisplayLink + script `monitor-toggle` pour basculer entre dispositions

## Outils de dev

- **Hardware**: KiCad (électronique), FreeCAD (CAO 3D)
- **Embedded**: STM32 (ST-Link) + ESP-IDF (ESP32)
- **.NET**: JetBrains Rider
- **AI/ML**: Outils IA (modules/dev/ai.nix)

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
# Rebuild seulement (applique la config actuelle)
update

# Update flake + rebuild (met à jour les paquets et applique)
upgrade

# Voir la liste détaillée des mises à jour disponibles sans les appliquer
# Affiche : paquets mis à jour (ancien→nouveau), paquets ajoutés/supprimés, taille
check-updates

# Garbage collect (nettoie les anciennes générations)
clean
```

## Structure

```
nixos-config/
├── flake.nix                    # Point d'entrée
├── hosts/nixos/                 # Config machine
│   ├── default.nix
│   └── hardware-configuration.nix
├── modules/
│   ├── desktop/                 # hyprland, sway, sddm, waybar
│   ├── hardware/                # DisplayLink, USB serial, DNS, SMB
│   ├── dev/                     # KiCad, STM32, ESP-IDF, FreeCAD, Rider, AI
│   └── apps/                    # Discord, GitHub Desktop, Valent
└── home/                        # Home-manager
    ├── mae.nix                  # Config principale + scripts
    ├── hypr/                    # Config Hyprland (modulaire)
    │   ├── hyprland.conf
    │   ├── monitors.conf
    │   ├── keybinds.conf
    │   └── ...
    ├── sway/config              # Config Sway
    ├── waybar/                  # Configs waybar (hyprland/sway)
    ├── nvim/                    # LazyVim config
    └── shell/aliases.nix        # Aliases partagés
```

## Raccourcis Hyprland

| Raccourci | Action |
|-----------|--------|
| `Mod+Return` | Terminal (alacritty) |
| `Mod+B` | Navigateur (Firefox) |
| `Mod+Space` / `Mod+D` | Launcher (fuzzel) |
| `Mod+E` | Explorateur de fichiers (Dolphin) |
| `Mod+Q` | Fermer fenêtre |
| `Mod+H/J/K/L` | Navigation (vim-style) |
| `Mod+Shift+H/J/K/L` | Déplacer fenêtre |
| `Mod+1-5` | Workspaces |
| `Mod+F` | Fullscreen |
| `Mod+Shift+M` | **Basculer profils d'écrans** (Bureau/Docked) |
| `Mod+Shift+W` | Relancer waybar |
| `Mod+Shift+E` | Quitter Hyprland |

## Notes spécifiques

### Multi-écrans

La gestion des écrans est native dans Hyprland via `monitors.conf` et le script `monitor-toggle`:

- **Profil Bureau** : Écrans DisplayLink côte à côte (horizontal)
- **Profil Docked** : Écrans DisplayLink vertical (écran du haut avec rotation 180°)

Basculer avec `Mod+Shift+M` ou lancer `monitor-toggle` dans un terminal.

### ESP-IDF

ESP-IDF est installé via le flake `nixpkgs-esp-dev`. Utilise l'alias pour sourcer l'environnement:

```bash
get_idf  # Source ~/esp/esp-idf/export.sh
```

### DisplayLink

Le driver DisplayLink nécessite d'accepter l'EULA de Synaptics. Le téléchargement doit être fait manuellement avant le premier rebuild.

⚠️ **Important** : Débrancher le hub DisplayLink avant le boot, le rebrancher après login pour éviter des problèmes de stabilité.

### Valent (KDE Connect)

Installer **KDE Connect** sur ton téléphone (Android/iOS). Valent se connectera automatiquement via le réseau local (ports 1714-1764 ouverts).

### Dolphin

Dolphin est configuré avec le support complet :
- **Archives** : Extraction via Ark (7z, rar, zip)
- **SMB** : Accès aux partages réseau
- **Thumbnails** : Aperçus vidéos, images, PDF
- **Open With** : Associations MIME configurées pour mpv, imv, alacritty

## Documentation

Voir [CLAUDE.md](CLAUDE.md) pour la documentation complète destinée à Claude Code (architecture, modules, conventions).
