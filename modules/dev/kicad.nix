{ config, pkgs, ... }:

let
  # Forcer XWayland pour KiCad — wxWidgets gère mal les dialogues modaux en Wayland natif
  # (popups de propriétés invisibles sous Hyprland)
  kicadX11 = pkgs.kicad.overrideAttrs (old: {
    makeWrapperArgs = old.makeWrapperArgs ++ [
      "--set GDK_BACKEND x11"
    ];
  });
in
{
  environment.systemPackages = [
    kicadX11

    # Java requis pour le plugin Freerouting (nécessite Swing/java.desktop)
    pkgs.jre

    # Outils complémentaires pour l'électronique
    # pkgs.ngspice        # Simulation SPICE
    # pkgs.gerbv          # Visualiseur Gerber
  ];
}
