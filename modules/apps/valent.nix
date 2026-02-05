{ config, pkgs, ... }:

{
  # Valent - Alternative légère à KDE Connect (GTK4/libadwaita)
  environment.systemPackages = with pkgs; [
    valent
  ];

  # Ouvrir les ports pour la communication avec le téléphone
  networking.firewall = {
    allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
    allowedUDPPortRanges = [{ from = 1714; to = 1764; }];
  };
}
