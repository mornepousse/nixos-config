{ pkgs }:
let
  wallpaper = import ./wallpaper.nix { inherit pkgs; };
  powerMenu = import ./power-menu.nix { inherit pkgs; };
  projectScaffolds = import ./project-scaffolds.nix { inherit pkgs; };
  nasUtils = import ./nas-utils.nix { inherit pkgs; };
in
wallpaper ++ powerMenu ++ projectScaffolds ++ nasUtils
