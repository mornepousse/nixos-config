{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # FreeCAD
    # freecad      # Désactivé temporairement: incompatibilité Boost 1.89.0

    # Outils complémentaires CAO
    # openscad      # CAO paramétrique
    # prusa-slicer  # Slicer pour impression 3D
  ];
}
