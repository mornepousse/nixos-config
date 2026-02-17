{ config, pkgs, ... }:

{
  # Nemo - File manager
  environment.systemPackages = with pkgs; [
    nemo

    # Support réseau SMB/CIFS et NFS
    gvfs
    nfs-utils

    # Thumbnails vidéo
    ffmpegthumbnailer

    # Gestionnaire d'archives
    file-roller

    # Utilitaires de compression/décompression
    p7zip
    unzip
    unrar
    zip

    # Thèmes GTK + Icônes
    catppuccin-gtk
    adwaita-icon-theme
    papirus-icon-theme
  ];
}
