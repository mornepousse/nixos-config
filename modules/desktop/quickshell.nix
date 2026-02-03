{ config, pkgs, ... }:

{
  # Quickshell - Shell/Bar moderne pour Wayland
  environment.systemPackages = with pkgs; [
    
    noctalia-shell
    
  ];
}
