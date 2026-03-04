{ config, pkgs, inputs, ... }:

{
  # Hyprland - Compositor Wayland moderne avec animations
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Packages identiques à Sway (partagés entre les deux)
  environment.systemPackages = with pkgs; [
    # Apps de base
    firefox
    ungoogled-chromium
    alacritty
    kitty
    fuzzel

    # Thème d'icônes
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
    hyprpaper  # Alternative native Hyprland

    # Lock screen
    swaylock
    swayidle

    # Utilitaires
    brightnessctl
    playerctl
    pamixer

    # Polkit authentication agent (popup mot de passe pour apps root)
    polkit_gnome
  ];

  # XDG Portal pour Hyprland
  # - xdg-desktop-portal-hyprland est ajouté automatiquement par programs.hyprland.enable
  #   Il gère : Screenshot, ScreenCast, GlobalShortcuts
  # - xdg-desktop-portal-gtk gère tout le reste : FileChooser, Notifications, Print, etc.
  # - wlr.enable = false car le portal Hyprland natif remplace xdg-desktop-portal-wlr
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common = {
        # Par défaut, utiliser le portal GTK pour toutes les interfaces
        default = [ "gtk" ];
      };
      Hyprland = {
        # Hyprland gère screenshot/screencast/shortcuts nativement
        default = [ "hyprland" "gtk" ];
      };
    };
  };

  # Variables d'environnement Wayland (identiques à Sway)
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };

  # Fonts (identiques à Sway)
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    font-awesome
  ];
}
