{ config, pkgs, ... }:

{
  # Cache DNS local via systemd-resolved
  # Accélère la résolution DNS en cachant les réponses localement
  services.resolved = {
    enable = true;
    settings.Resolve = {
      FallbackDNS = [
        "8.8.8.8"
        "9.9.9.9"
      ];
      DNSSEC = "false";
    };
  };

  # Cloudflare en priorité, Pi-hole disponible quand sur le réseau local
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "192.168.1.4"
  ];

  # NetworkManager délègue le DNS à systemd-resolved
  networking.networkmanager.dns = "systemd-resolved";

  # Domaines locaux YunoHost (ThinkPad NAS)
  networking.extraHosts = ''
    192.168.1.4 nas.local
    192.168.1.4 jelly.local
    192.168.1.4 pihole.local
    192.168.1.4 esphome.local
  '';
}
