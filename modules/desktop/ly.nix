{ config, pkgs, ... }:

{
  # Ly - Display manager TUI minimaliste
  services.displayManager.ly = {
    enable = true;
    settings = {
      # Animation
      animation = "matrix";
      
      # Couleurs (optionnel, personnalisable)
      # bg = 0;
      # fg = 7;
      # border_color = 4;
    };
  };

  # Désactiver les autres display managers
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.displayManager.sddm.enable = false;
  services.xserver.displayManager.lightdm.enable = false;
}
