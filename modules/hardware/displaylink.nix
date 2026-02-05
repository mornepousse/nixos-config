{ config, pkgs, ... }:

{
  # Driver DisplayLink pour hubs/docks Dell (et autres)
  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];

  # Module kernel evdi nécessaire pour DisplayLink
  boot.extraModulePackages = with config.boot.kernelPackages; [
    evdi
  ];

  # Charger le module au démarrage
  boot.kernelModules = [ "evdi" ];

  # Paquet DisplayLink
  environment.systemPackages = with pkgs; [
    displaylink
  ];

  # Service DisplayLink
  systemd.services.dlm.wantedBy = [ "multi-user.target" ];
}
