{ config, pkgs, inputs, ... }:

{
  # Quickshell - Shell/Bar moderne pour Wayland
  environment.systemPackages = [
    inputs.quickshell.packages.${pkgs.system}.default
  ];

  # Dépendances utiles pour quickshell
  environment.systemPackages = with pkgs; [
    # Pour les scripts et widgets
    jq
    socat
    
    # Pour les infos système
    lm_sensors
    acpi
  ];
}
