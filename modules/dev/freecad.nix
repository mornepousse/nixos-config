{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # FreeCAD
    freecad
    
    # Outils complémentaires CAO
    # openscad      # CAO paramétrique
    # prusa-slicer  # Slicer pour impression 3D
  ];
}
