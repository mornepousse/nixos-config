# NixOS Configuration - Instructions Claude Code

## Architecture

Configuration **NixOS basée sur flakes** avec Home Manager. Setup **Hyprland / Sway + waybar + SDDM** (Wayland).

- **`flake.nix`** - Point d'entrée, définit les inputs (nixpkgs, home-manager, nixpkgs-esp-dev, rust-overlay, zen-browser)
- **`hosts/morthinkpad/`** - Config machine principale (avec DisplayLink)
- **`hosts/x230t/`** - Config machine secondaire (sans DisplayLink)
- **`hosts/nixos/`** - Alias legacy vers morthinkpad
- **`modules/`** - Modules NixOS organisés par catégorie (hardware, desktop, dev, apps)
- **`home/`** - Config Home Manager pour l'utilisateur `mae` (dotfiles Hyprland/Sway, waybar, fuzzel, nvim, shell)

## Structure des Modules

Les modules dans `modules/` sont organisés en 4 catégories :

### Hardware (`modules/hardware/`)
- `displaylink.nix` - Driver pour hub DisplayLink
- `dns.nix` - Configuration DNS
- `smb.nix` - Partages réseau SMB/CIFS
- `nfs.nix` - Partages réseau NFS
- `usb-serial.nix` - Support USB série (CH340, CP210x)

### Desktop (`modules/desktop/`)
- `hyprland.nix` - Wayland compositor moderne avec animations (recommandé)
- `console.nix` - Configuration console/TTY
- `desktop-others.nix` - Paquets desktop divers
- `quickshell.nix` - Contient waybar (barre de statut Wayland)

### Dev (`modules/dev/`)
- `ai.nix` - Outils IA/ML
- `esp-idf.nix` - ESP32 development via nixpkgs-esp-dev (tous les chips)
- `freecad.nix` - CAO 3D
- `kicad.nix` - Conception PCB
- `rider.nix` - IDE .NET/C#
- `stm32.nix` - Développement STM32 (règles ST-Link)
- `slint-rust.nix` - Développement Slint + Rust
- `qt-quick.nix` - Développement Qt Quick
- `ssh.nix` - Configuration SSH
- `dev_other.nix` - Outils dev divers

### Apps (`modules/apps/`)
- `thunar.nix` - Gestionnaire de fichiers Thunar (gvfs, tumbler, thumbnails, archives, plugins, "Open in Terminal")
- `discord.nix` - Client Discord
- `disk-tools.nix` - Gestion disques (KDE Partition Manager, disktui, filelight, gdu, udisks2 + polkit rules)
- `flatpak.nix` - Support Flatpak

Chaque module est autonome avec ses packages, services et règles udev :
```nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ ... ];
  services.udev.extraRules = ''...'';  # Règles hardware si nécessaire
}
```

## Ajouter un Logiciel

1. **Module hardware** : Créer `modules/hardware/<nom>.nix`, l'importer dans `hosts/morthinkpad/default.nix`
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
  - `startup.conf` - Applications au démarrage (polkit, waybar, mako, applets, clipboard)
  - `waybar/config-hyprland.json` - Barre de statut Hyprland
- **Sway** :
  - `home/sway/config` - Config Sway
  - `home/waybar/config-sway.json` + `style.css` - Barre de statut Sway
- **Commun** :
  - `home/fuzzel/fuzzel.ini` - Lanceur d'applications (dmenu Wayland)

### Shell
- **Aliases** : Centralisés dans `home/shell/aliases.nix` (partagés zsh/fish)
- **Zsh** : `initContent` pour init personnalisé
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

Scripts ESP-IDF dans `modules/dev/esp-idf.nix` :
- `esp-shell` - Entre dans un shell nix develop avec ESP-IDF (tous les chips)
- `code-esp` - Lance VSCode avec l'environnement ESP-IDF complet

## Commandes

```bash
# Appliquer les changements
sudo nixos-rebuild switch --flake ~/nixos-config#morthinkpad

# Raccourcis (alias dans home/shell/aliases.nix)
update          # rebuild et applique la config actuelle (sans mise à jour)

# Mises à jour segmentées
upgrade         # quotidien — met à jour nixpkgs + home-manager + zen-browser + affinity
                # (Firefox, VSCode, Discord/Vesktop, Zen Browser, Affinity, etc.)
upgrade-system  # 1-2x/mois — met à jour nixpkgs + home-manager seuls (core système)
upgrade-dev     # selon besoin — met à jour rust-overlay + nixpkgs-esp-dev (toolchains dev)
upgrade-all     # occasionnel — met à jour TOUS les inputs d'un coup
check-updates   # prévisualise les changements (build temporaire + nvd diff, sans appliquer)

clean           # garbage collect

# ESP-IDF
esp-shell       # Shell avec ESP-IDF pour tous les chips ESP32
code-esp        # VSCode avec environnement ESP-IDF

# Git shortcuts
gs, ga, gc, gp  # git status/add/commit/push
```

## Hardware

- **DisplayLink** : Télécharger le driver manuellement avant le premier build. La connexion au hub prend 10-30s (comportement normal). Débrancher le hub DisplayLink avant le boot, le rebrancher après login
- **USB série (CH340/CP210x)** : Règles udev auto ; utilisateur dans groupe `dialout`
- **STM32** : Règles ST-Link dans `modules/dev/stm32.nix` ; groupe `plugdev`
- **ESP32** : Via nixpkgs-esp-dev (nix develop) ; scripts `esp-shell` et `code-esp` ; extension VSCode ESP-IDF incompatible NixOS (binaires non-FHS)
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
- **Explorateur de fichiers** : Thunar avec gvfs, tumbler, thumbnails (vidéo/PDF/HEIF), archives (thunar-archive-plugin + file-roller), "Open in Terminal" (kitty via helpers.rc)
- **Curseur** : breeze_cursors (KDE)
- **Applets** : pavucontrol (audio), nm-applet (WiFi), blueman-applet (Bluetooth)
- **Clipboard** : cliphist pour Hyprland
- **Polkit** : Agent polkit-gnome lancé via systemd user service + fallback dans `startup.conf`
- **Raccourcis utiles** :
  - `Mod+Shift+M` : Basculer entre profils d'écrans (Bureau/Docked)
  - `Mod+Shift+W` : Relancer waybar après reconfiguration écrans

## Système

- **User** : `mae`, shell par défaut zsh, groupes : wheel, networkmanager, dialout, plugdev, uucp
- **Bootloader** : systemd-boot, limite 10 entrées
- **Kernel** : linuxPackages_zen
- **Locale** : Europe/Paris (fr_FR.UTF-8 pour formats, en_US.UTF-8 pour système)
- **Audio** : PipeWire avec ALSA/Pulse support
- **Polkit** : Activé + agent polkit-gnome (systemd user service) + rules udisks2/partitionmanager pour groupe wheel
- **Keyring** : gnome-keyring pour stocker tokens (GitHub Copilot, etc.)
- **Logind** : Lid switch ignoré sur secteur / avec écran externe (mode docked)
- **Disques** : udisks2 activé, polkit rules pour KDE Partition Manager et disktui

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

- Flake `nixpkgs-esp-dev` pour toolchain ESP32 (ESP-IDF) - tous les chips supportés
- Flake `rust-overlay` pour toolchain Rust à jour
- Flake `zen-browser` pour navigateur Zen
- Driver DisplayLink nécessite prefetch manuel avant premier rebuild
- Plugins LazyVim gérés par lazy.nvim (pas par Nix)
- Wallpapers attendus dans `~/Pictures` (config waypaper)
