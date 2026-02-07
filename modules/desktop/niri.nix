{ config, pkgs, inputs, ... }:

{
  # Niri - installé comme package + enregistré comme session
  environment.systemPackages = with pkgs; [
    niri
    xwayland-satellite  # Pour les apps X11
    
    # Apps de base
    firefox
    foot
    alacritty
    fuzzel
    nautilus
    
    # Thème d'icônes pour Nautilus
    adwaita-icon-theme
    
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

  # Enregistrer niri comme session
  services.displayManager.sessionPackages = [ pkgs.niri ];

  # XWayland pour les applications X11 (STM32CubeMX, etc.)
  programs.xwayland.enable = true;

  # XDG Portal pour les apps Wayland
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";  # Fix pour le warning portal
  };

  # Variables d'environnement Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    font-awesome          # Icônes modernes pour waybar
  ];
}
