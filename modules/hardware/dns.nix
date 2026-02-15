{ config, pkgs, ... }:

{
  # Configuration DNS personnalisée
  # Désactive le DNS de NetworkManager pour utiliser nos propres serveurs
  networking.networkmanager.dns = "none";

  # Serveurs DNS : Pi-hole en priorité, Cloudflare en fallback
  networking.nameservers = [
    "192.168.1.4"
    "1.1.1.1"
    "1.0.0.1"
  ];

  # Domaines locaux YunoHost (ThinkPad NAS)
  networking.extraHosts = ''
    192.168.1.4 nas.local
    192.168.1.4 jelly.local
    192.168.1.4 pihole.local
    192.168.1.4 esphome.local
  '';
}
