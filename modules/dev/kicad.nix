{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # KiCad avec toutes les bibliothèques
    kicad
    
    # Bibliothèques additionnelles
    kicad-symbols
    kicad-footprints
    kicad-packages3d
    
    # Outils complémentaires pour l'électronique
    # ngspice        # Simulation SPICE
    # gerbv          # Visualiseur Gerber
  ];
}
