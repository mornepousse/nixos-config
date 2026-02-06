# NixOS Configuration - Instructions Copilot

## Architecture

Configuration **NixOS basée sur flakes** avec Home Manager. Structure modulaire :

- **`flake.nix`** - Point d'entrée, définit les inputs (nixpkgs, home-manager, nixpkgs-esp-dev)
- **`hosts/nixos/`** - Config machine ; `default.nix` importe tous les modules
- **`modules/`** - Modules NixOS réutilisables (desktop, hardware, dev, apps)
- **`home/`** - Config Home Manager pour l'utilisateur `mae` (dotfiles nvim, niri, shell)

## Patterns Clés

### Structure d'un Module
Chaque module dans `modules/` est autonome avec ses packages, services et règles udev :
```nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ ... ];
  services.udev.extraRules = ''...'';  # Règles hardware
}
```

### Ajouter un Logiciel
1. **App système** : Créer `modules/apps/<nom>.nix`, l'importer dans `hosts/nixos/default.nix`
2. **Outil dev** : Créer `modules/dev/<nom>.nix` avec packages + règles udev si hardware
3. **Config utilisateur** : Ajouter à `home/mae.nix` ou créer un sous-dossier dans `home/`

### Intégration Home Manager
- Les dotfiles vont dans `home/` et sont liés via `xdg.configFile` ou `home.file`
- Les alias shell sont centralisés dans `home/shell/aliases.nix` (partagés zsh/fish)
- La config Neovim (LazyVim) est dans `home/nvim/` et symlinked telle quelle

## Commandes

```bash
# Appliquer les changements
sudo nixos-rebuild switch --flake .#nixos

# Raccourcis (alias shell)
update    # rebuild seulement
upgrade   # update flake + rebuild
clean     # garbage collect
```

## Hardware

- **DisplayLink** : Télécharger le driver manuellement avant le premier build (voir README). ⚠️ La connexion au hub prend du temps (comportement normal, attendre 10-30s)
- **USB série (CH340/CP210x)** : Règles udev auto ; utilisateur doit être dans groupe `dialout`
- **STM32** : Règles ST-Link dans `modules/dev/stm32.nix` ; groupe `plugdev`
- **ESP32** : PlatformIO fonctionne par défaut ; scripts `esp-shell`/`code-esp` disponibles pour ESP-IDF natif si besoin

## Conventions

- **Commentaires en français** acceptés
- **Packages unfree autorisés** : `nixpkgs.config.allowUnfree = true`
- **Modules atomiques** : Un seul sujet par fichier module
- **stateVersion** : Actuellement `26.05` - ne pas modifier sans migration

## Dépendances Externes
disponible pour ESP-IDF (optionnel, PlatformIO utilisé en pratique)
- Flake `nixpkgs-esp-dev` pour toolchain ESP32
- Driver DisplayLink nécessite prefetch manuel avant premier rebuild
- Plugins LazyVim gérés par lazy.nvim (pas par Nix)
