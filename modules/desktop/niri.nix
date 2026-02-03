{ config, pkgs, inputs, ... }:

{
  # Niri - installé comme package + enregistré comme session
  environment.systemPackages = with pkgs; [
    niri
    
    # Apps de base (comme ta config actuelle)
    firefox
    foot
    alacritty
    fuzzel
    nautilus
    vscode
    
    # Launcher
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
  ];

  # Enregistrer niri comme session (comme ta config)
  services.displayManager.sessionPackages = [ pkgs.niri ];

  # XDG Portal pour les apps Wayland (comme ta config)
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Variables d'environnement Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";  # Pour les apps Electron (Discord, VSCode...)
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];
}
