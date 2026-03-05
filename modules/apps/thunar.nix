{ config, pkgs, ... }:

{
  # Thunar - File manager (module NixOS dédié)
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin    # Extraction/compression via file-roller
      thunar-volman            # Gestion automatique des volumes USB
      thunar-media-tags-plugin # Tags audio (ID3, OGG)
    ];
  };

  # Sauvegarder les préférences Thunar hors XFCE
  programs.xfconf.enable = true;

  # Services essentiels
  services.gvfs.enable = true;     # Trash, montage réseau, SMB, MTP
  services.tumbler.enable = true;  # Thumbnails automatiques

  # Liens vers les thumbnailers installés
  environment.pathsToLink = [ "share/thumbnailers" ];

  environment.systemPackages = with pkgs; [
    # Thumbnails étendus
    ffmpegthumbnailer  # Thumbnails vidéo (mp4, mkv, avi, webm...)
    poppler            # Thumbnails PDF
    libheif            # Thumbnails HEIF/AVIF

    # Gestionnaire d'archives (requis par thunar-archive-plugin)
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

    # Dépendance pour xdg-open
    xdg-utils
  ];
}
