{ config, pkgs, ... }:

{
  # Sway - Compositor Wayland i3-compatible
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      # Apps de base
      firefox
      foot
      alacritty
      fuzzel

      # Dolphin - File manager KDE avec plugins complets
      kdePackages.dolphin
      kdePackages.dolphin-plugins
      kdePackages.kio-extras  # SMB, thumbnails, protocoles réseau
      kdePackages.ark  # Gestionnaire d'archives (extraction intégrée)
      kdePackages.ffmpegthumbs  # Thumbnails vidéos
      kdePackages.kdegraphics-thumbnailers  # Thumbnails images
      kdePackages.kimageformats  # Formats images supplémentaires
      kdePackages.kde-cli-tools  # kioclient pour ouvrir fichiers
      kdePackages.kio-admin  # Accès root pour fichiers

      # Support archives
      p7zip  # 7z, rar
      unzip
      unrar

      # Thèmes d'icônes
      adwaita-icon-theme
      kdePackages.breeze-icons

      # Notifications
      mako
      libnotify

      # Screenshot / Screen recording
      grim
      slurp
      wl-clipboard

      # Wallpaper
      swaybg

      # Lock screen
      swaylock
      swayidle

      # Utilitaires
      brightnessctl
      playerctl
      pamixer
    ];
  };

  # XWayland pour les applications X11 (STM32CubeMX, etc.)
  programs.xwayland.enable = true;

  # XDG Portal pour les apps Wayland (même config que niri)
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # Variables d'environnement Wayland (identiques à niri)
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };

  # Fonts (identiques à niri)
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    font-awesome
  ];
}
