{ config, pkgs, inputs, ... }:

{
  # Activer niri via le flake
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # XDG Portal pour les apps Wayland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  # Variables d'environnement Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";  # Pour les apps Electron (Discord, VSCode...)
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };

  # Packages utiles pour niri
  environment.systemPackages = with pkgs; [
    # Launcher
    fuzzel
    wofi
    
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
    
    # Terminal
    foot
    alacritty
  ];

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
  ];
}
