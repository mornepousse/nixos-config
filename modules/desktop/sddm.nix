{ config, pkgs, ... }:

{
  # SDDM - Display manager moderne
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;  # Mode Wayland natif pour meilleure compatibilité Sway
    package = pkgs.kdePackages.sddm;

    # Thème Catppuccin
    theme = "catppuccin-mocha";

    # Settings
    settings = {
      Theme = {
        CursorTheme = "breeze_cursors";
        CursorSize = 24;
      };
      # Configuration pour écrans externes en mode docked
      X11 = {
        # Activer automatiquement tous les écrans détectés
        DisplayCommand = "${pkgs.writeShellScript "sddm-setup-monitors" ''
          sleep 2
          ${pkgs.xorg.xrandr}/bin/xrandr --auto
        ''}";
      };
    };
  };

  # Thème Catppuccin pour SDDM
  environment.systemPackages = with pkgs; [
    catppuccin-sddm
  ];

  # Assurer que X11 est disponible pour compatibilité
  services.xserver.enable = true;
}
