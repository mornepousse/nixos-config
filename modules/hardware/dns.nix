{ config, pkgs, ... }:

{
  # Configuration DNS personnalisée
  # Désactive le DNS de NetworkManager pour utiliser nos propres serveurs
  networking.networkmanager.dns = "none";

  # Serveurs DNS (Cloudflare - rapide et privé)
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    # IPv6 Cloudflare (optionnel)
    # "2606:4700:4700::1111"
    # "2606:4700:4700::1001"
  ];

  # Alternatives si tu veux changer :
  # Google : "8.8.8.8" "8.8.4.4"
  # Quad9 (bloque malware) : "9.9.9.9" "149.112.112.112"
  # AdGuard (bloque pubs) : "94.140.14.14" "94.140.15.15"
}
