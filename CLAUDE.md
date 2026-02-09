# NixOS Configuration - Instructions Claude Code

## Architecture

Configuration **NixOS basée sur flakes** avec Home Manager. Setup **Hyprland / Sway + waybar + SDDM** (Wayland).

- **`flake.nix`** - Point d'entrée, définit les inputs (nixpkgs, home-manager, nixpkgs-esp-dev)
- **`hosts/nixos/`** - Config machine ; `default.nix` importe tous les modules
- **`modules/`** - Modules NixOS organisés par catégorie (hardware, desktop, dev, apps)
- **`home/`** - Config Home Manager pour l'utilisateur `mae` (dotfiles Hyprland/Sway, waybar, fuzzel, nvim, shell)

## Structure des Modules

Les modules dans `modules/` sont organisés en 4 catégories :

### Hardware (`modules/hardware/`)
- `displaylink.nix` - Driver pour hub DisplayLink
- `dns.nix` - Configuration DNS
- `smb.nix` - Partages réseau SMB/CIFS
- `usb-serial.nix` - Support USB série (CH340, CP210x)

### Desktop (`modules/desktop/`)
- `hyprland.nix` - Wayland compositor moderne avec animations (recommandé)
- `sway.nix` - Wayland compositor i3-compatible
- `sddm.nix` - Display manager avec support Wayland natif (thème Catppuccin)
- `quickshell.nix` - Contient waybar (barre de statut Wayland)

### Dev (`modules/dev/`)
- `ai.nix` - Outils IA/ML
- `esp-idf.nix` - ESP32 development (ESP-IDF + PlatformIO)
- `freecad.nix` - CAO 3D
- `kicad.nix` - Conception PCB
- `rider.nix` - IDE .NET/C#
- `stm32.nix` - Développement STM32 (règles ST-Link)

### Apps (`modules/apps/`)
- `discord.nix` - Client Discord
- `github-desktop.nix` - GitHub Desktop
- `valent.nix` - KDE Connect pour GNOME (connectivité mobile)

Chaque module est autonome avec ses packages, services et règles udev :
```nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ ... ];
  services.udev.extraRules = ''...'';  # Règles hardware si nécessaire
}
```

## Ajouter un Logiciel

1. **Module hardware** : Créer `modules/hardware/<nom>.nix`, l'importer dans `hosts/nixos/default.nix`
2. **Module desktop** : Créer `modules/desktop/<nom>.nix` pour composants Wayland/graphiques
3. **Outil dev** : Créer `modules/dev/<nom>.nix` avec packages + règles udev si hardware
4. **App système** : Créer `modules/apps/<nom>.nix` pour applications standalone
5. **Config utilisateur** : Ajouter à `home/mae.nix` ou créer un sous-dossier dans `home/`

## Configuration Home Manager

### Dotfiles Wayland
Les fichiers de config sont symlinqués depuis `home/` :
- **Hyprland** (config modulaire dans `home/hypr/`) :
  - `hyprland.conf` - Config principale (source tous les modules)
  - `env.conf`, `monitors.conf`, `input.conf`, `keybinds.conf`, etc. - Modules spécialisés
  - `waybar/config-hyprland.json` - Barre de statut Hyprland
- **Sway** :
  - `home/sway/config` - Config Sway
  - `home/waybar/config-sway.json` + `style.css` - Barre de statut Sway
- **Commun** :
  - `home/fuzzel/fuzzel.ini` - Lanceur d'applications (dmenu Wayland)

### Shell
- **Aliases** : Centralisés dans `home/shell/aliases.nix` (partagés zsh/fish)
- **Zsh** : `initContent` pour init personnalisé (ESP-IDF, fastfetch)
- **Fish** : `interactiveShellInit` pour init personnalisé
- **Starship** : Prompt configuré dans `home/mae.nix`

### Neovim
- Config LazyVim dans `home/nvim/lua/` avec structure :
  - `lua/config/` - Configuration LazyVim
  - `lua/plugins/` - Plugins personnalisés
- Packages requis installés : git, gcc, ripgrep, fd, lazygit
- Plugins gérés par lazy.nvim (pas par Nix)

### Scripts Custom
Scripts shell intégrés via `writeShellScriptBin` dans `home/mae.nix` :
- `set-wallpaper` / `restore-wallpaper` - Gestion wallpaper swaybg
- `power-menu` - Menu power avec fuzzel, détection auto compositor (shutdown/reboot/logout)
- `monitor-toggle` - Basculer entre profils d'écrans (Bureau côte à côte / Docked vertical) via `hyprctl`

## Commandes

```bash
# Appliquer les changements
sudo nixos-rebuild switch --flake ~/nixos-config#nixos

# Raccourcis (alias dans home/shell/aliases.nix)
update          # rebuild seulement
upgrade         # update flake + rebuild
check-updates   # dry-build pour voir les changements
clean           # garbage collect

# Git shortcuts
gs, ga, gc, gp  # git status/add/commit/push
```

## Hardware

- **DisplayLink** : Télécharger le driver manuellement avant le premier build. ⚠️ La connexion au hub prend 10-30s (comportement normal). **Important** : Débrancher le hub DisplayLink avant le boot, le rebrancher après login pour éviter crash de Sway (limitation DisplayLink)
- **USB série (CH340/CP210x)** : Règles udev auto ; utilisateur dans groupe `dialout`
- **STM32** : Règles ST-Link dans `modules/dev/stm32.nix` ; groupe `plugdev`
- **ESP32** : PlatformIO + ESP-IDF ; alias `get_idf` pour sourcer export.sh
- **Bluetooth** : Activé au boot avec bluetui et blueman

## Wayland/Desktop

- **Compositeurs** :
  - **Hyprland** (recommandé) : Compositor moderne avec animations, tiling dynamique
  - **Sway** : Compositor i3-compatible, plus sobre
- **Display Manager** : SDDM avec support Wayland natif (thème Catppuccin Mocha)
- **Barre** : waybar (config JSON + CSS, adaptée par compositor)
- **Launcher** : fuzzel (dmenu Wayland)
- **Notifications** : mako (timeout 5s, border-radius 8)
- **Wallpaper** : swaybg via scripts `set-wallpaper`/`restore-wallpaper`
- **Multi-écrans** :
  - **Hyprland** : Config native dans `monitors.conf` + script `monitor-toggle` (`Mod+Shift+M`)
  - **Sway** : wdisplays (GUI) pour config manuelle
- **Explorateur de fichiers** : Dolphin (KDE) avec kio-extras (SMB, archives, thumbnails)
- **Curseur** : breeze_cursors (KDE)
- **Applets** : pavucontrol (audio), nm-applet (WiFi), blueman-applet (Bluetooth)
- **Clipboard** : cliphist pour Hyprland
- **Raccourcis utiles** :
  - `Mod+Shift+M` : Basculer entre profils d'écrans (Bureau/Docked)
  - `Mod+Shift+W` : Relancer waybar après reconfiguration écrans

## Système

- **User** : `mae`, shell par défaut zsh, groupes : wheel, networkmanager, dialout, plugdev, uucp
- **Bootloader** : systemd-boot, limite 10 entrées
- **Kernel** : linuxPackages_latest
- **Locale** : Europe/Paris (fr_FR.UTF-8 pour formats, en_US.UTF-8 pour système)
- **Audio** : PipeWire avec ALSA/Pulse support
- **Polkit** : Activé pour privilèges GUI
- **Keyring** : gnome-keyring pour stocker tokens (GitHub Copilot, etc.)
- **Logind** : Lid switch ignoré sur secteur / avec écran externe (mode docked)

## Nix Settings

- **Flakes** : Activés (`experimental-features`)
- **Auto-optimise** : Store optimization automatique
- **Keep derivations/outputs** : Garde les sources (évite re-téléchargement DisplayLink)
- **Garbage collection** : Hebdomadaire, garde 30 jours
- **Unfree packages** : Autorisés globalement

## Conventions

- **Commentaires en français** acceptés et encouragés
- **Modules atomiques** : Un seul sujet par fichier module
- **Organisation par catégorie** : hardware/desktop/dev/apps
- **stateVersion** : `26.05` - NE JAMAIS modifier sans migration

## Dépendances Externes

- Flake `nixpkgs-esp-dev` pour toolchain ESP32 (ESP-IDF)
- Driver DisplayLink nécessite prefetch manuel avant premier rebuild
- Plugins LazyVim gérés par lazy.nvim (pas par Nix)
- Wallpapers attendus dans `~/Pictures` (config waypaper)
