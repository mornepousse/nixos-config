{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    signal-cli
    vivaldi
    #brave
    vitetris
    kdePackages.elisa
    kdePackages.ghostwriter
    inkscape
    ardour
    mgba
    legcord
  ];
}
