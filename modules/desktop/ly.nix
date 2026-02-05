{ config, pkgs, ... }:

{
  # Ly - Display manager TUI minimaliste
  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "doom";
    };
  };
}
