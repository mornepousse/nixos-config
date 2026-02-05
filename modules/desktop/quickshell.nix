{ config, pkgs, ... }:

{
  # Quickshell - Shell/Bar moderne pour Wayland
  environment.systemPackages = with pkgs; [
    noctalia-shell
  ];

  # Service UPower nécessaire pour le widget batterie
  services.upower.enable = true;
}
