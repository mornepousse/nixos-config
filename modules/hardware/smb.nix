{ config, pkgs, ... }:

{
  # Support SMB/CIFS pour Nautilus
  services.gvfs = {
    enable = true;
    package = pkgs.gvfs;
  };

  # Tracker pour l'indexation de fichiers (nécessaire pour Nautilus)
  services.gnome.localsearch.enable = true;
  services.gnome.tinysparql.enable = true;

  # Paquets nécessaires pour SMB
  environment.systemPackages = with pkgs; [
    gvfs
    cifs-utils
    samba
  ];

  # Activer le client Samba
  services.samba = {
    enable = false;  # Pas besoin du serveur, juste le client
    package = pkgs.samba;
  };
}
