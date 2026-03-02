{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    signal-cli
    #brave
    vitetris
    kdePackages.elisa
    kdePackages.ghostwriter
    discord
    inkscape
    ardour
  ];
}
