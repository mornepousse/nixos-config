{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # KiCad (les bibliothèques sont incluses par défaut maintenant)
    kicad

    # Java requis pour le plugin Freerouting (nécessite Swing/java.desktop)
    jre

    # Outils complémentaires pour l'électronique
    # ngspice        # Simulation SPICE
    # gerbv          # Visualiseur Gerber
  ];
}
