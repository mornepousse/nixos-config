{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # claude-code géré via npm (pas Nix) — nixpkgs souvent en retard ou cassé
    nodejs
  ];
}