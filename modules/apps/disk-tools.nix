{ config, pkgs, ... }:

{
  # Outils de gestion et analyse des disques
  environment.systemPackages = with pkgs; [
    # KDE Partition Manager - Gestionnaire de partitions (intégration KDE)
    kdePackages.partitionmanager

    # Filelight - Visualisation graphique de l'espace disque (anneaux KDE)
    kdePackages.filelight

    # gdu - Analyseur d'espace disque en CLI (ncurses, rapide)
    gdu
  ];

  # Polkit nécessaire pour KDE Partition Manager (accès root via GUI)
  # Déjà activé dans la config système, mais mentionné ici pour référence
}
