{ config, pkgs, ... }:

{
  # Désactiver les display managers - login TTY uniquement
  services.displayManager.sddm.enable = false;
  services.xserver.enable = false;

  # Script de boot pour activer tous les moniteurs sur la console TTY
  boot.postBootCommands = ''
    sleep 2
    # Activer tous les écrans détectés
    ${pkgs.xrandr}/bin/xrandr --auto 2>/dev/null || true
  '';

  # Dépendances pour multi-écrans en TTY
  environment.systemPackages = with pkgs; [
    xrandr
    wdisplays
  ];
}
