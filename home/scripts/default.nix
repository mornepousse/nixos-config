{ pkgs }:
let
  wallpaper = import ./wallpaper.nix { inherit pkgs; };
  powerMenu = import ./power-menu.nix { inherit pkgs; };
  projectScaffolds = import ./project-scaffolds.nix { inherit pkgs; };
  nasUtils = import ./nas-utils.nix { inherit pkgs; };
  audioSwitcher = import ./audio-switcher.nix { inherit pkgs; };
  checkUpdates = import ./check-updates.nix { inherit pkgs; };
  dnsSwitcher = import ./dns-switcher.nix { inherit pkgs; };
  toolsMenu = import ./tools-menu.nix { inherit pkgs; };
in
wallpaper ++ powerMenu ++ projectScaffolds ++ nasUtils ++ audioSwitcher ++ checkUpdates ++ dnsSwitcher ++ toolsMenu
