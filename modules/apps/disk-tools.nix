{ config, pkgs, ... }:

{
  # Outils de gestion et analyse des disques
  environment.systemPackages = with pkgs; [
    # KDE Partition Manager - Gestionnaire de partitions (intégration KDE)
    kdePackages.partitionmanager

    # disktui - Gestionnaire de partitions moderne
    disktui

    # Filelight - Visualisation graphique de l'espace disque (anneaux KDE)
    kdePackages.filelight

    # gdu - Analyseur d'espace disque en CLI (ncurses, rapide)
    gdu

    # udisks2 - Daemon pour montage/démontage disques (requis pour permission GUI)
    udisks2
  ];

  # Activer le service udisks2
  services.udisks2.enable = true;

  # Polkit rules pour permettre la gestion des disques via GUI
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.freedesktop.udisks2") === 0 &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });

    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.kde.partitionmanager") === 0 &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
}
