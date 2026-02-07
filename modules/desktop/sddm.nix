{ config, pkgs, ... }:

{
  # SDDM - Display manager moderne avec support Wayland natif
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;  # Support Wayland natif pour niri
    package = pkgs.kdePackages.sddm;

    # Thème Catppuccin
    theme = "catppuccin-mocha";

    # Settings
    settings = {
      Theme = {
        CursorTheme = "breeze_cursors";
        CursorSize = 24;
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
