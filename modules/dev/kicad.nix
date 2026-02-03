{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # KiCad (les bibliothèques sont incluses par défaut maintenant)
    kicad
    
    # Outils complémentaires pour l'électronique
    # ngspice        # Simulation SPICE
    # gerbv          # Visualiseur Gerber
  ];
}
