{ config, pkgs, ... }:

{
  # Support SMB/CIFS
  services.gvfs = {
    enable = true;
    package = pkgs.gvfs;
  };

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
