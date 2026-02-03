{ config, pkgs, ... }:

{
  # Quickshell - Shell/Bar moderne pour Wayland
  environment.systemPackages = with pkgs; [
    quickshell
    
    # Dépendances utiles pour quickshell
    jq
    socat
    lm_sensors
    acpi
  ];
}
