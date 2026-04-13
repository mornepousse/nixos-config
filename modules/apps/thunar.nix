{ config, pkgs, lib, ... }:

{
  # Thunar - File manager (module NixOS dédié)
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
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

  # Liens vers les ressources partagées
  environment.pathsToLink = [
    "share/thumbnailers"
    "share/gsettings-schemas"  # Schemas gsettings (chemin NixOS spécifique)
  ];

  # Ajouter les schemas gsettings à XDG_DATA_DIRS pour que gio trouve le terminal
  environment.sessionVariables.XDG_DATA_DIRS = [
    "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
  ];

  environment.systemPackages = with pkgs; [
    # Thumbnails étendus
    ffmpegthumbnailer  # Thumbnails vidéo (mp4, mkv, avi, webm...)
    poppler            # Thumbnails PDF
    libheif            # Thumbnails HEIF/AVIF

    # Gestionnaire d'archives (requis par thunar-archive-plugin)
    # Wrappé avec les outils de compression dans le PATH
    (symlinkJoin {
      name = "file-roller-wrapped";
      paths = [ file-roller ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/file-roller \
          --prefix PATH : ${lib.makeBinPath [ zip unzip unrar rar p7zip ]}
      '';
    })

    # Utilitaires de compression/décompression (aussi dispo en CLI)
    p7zip
    unzip
    unrar
    rar            # Création d'archives .rar (propriétaire)
    zip

    # Thèmes GTK + Icônes
    catppuccin-gtk
    adwaita-icon-theme
    papirus-icon-theme

    # Dépendances XDG / XFCE
    xdg-utils
    exo                          # exo-open : lance les apps Terminal=true (nvim, etc.)
    gsettings-desktop-schemas    # Schemas GLib pour que gio trouve le terminal
  ];
}
