{ config, pkgs, ... }:

{
  # Waybar - Barre légère et configurable pour Wayland
  environment.systemPackages = with pkgs; [
    waybar
    # BACKUP: noctalia-shell (décommenter si waybar ne convient pas)
    # noctalia-shell
  ];

  # Service UPower nécessaire pour le widget batterie
  services.upower.enable = true;
}
