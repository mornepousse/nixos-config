{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Legcord — client Discord léger (installé via desktop-others.nix)
    # Ce module est conservé pour l'import dans les hosts
  ];
}
