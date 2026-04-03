{ pkgs }:
[
  (pkgs.writeShellScriptBin "dns-switch" ''
    # Profils DNS disponibles
    profiles="Cloudflare (1.1.1.1)
Google (8.8.8.8)
Quad9 (9.9.9.9)
Pi-hole local (192.168.1.4)
Cloudflare DoH (securisé)
AdGuard (bloqueur pubs)"

    # Afficher le DNS actuel
    current=$(resolvectl status 2>/dev/null | grep "Current DNS" | head -1 | awk '{print $NF}')
    selection=$(echo "$profiles" | fuzzel --dmenu -p "DNS actuel: $current  ->  ")

    [ -z "$selection" ] && exit 0

    case "$selection" in
      "Cloudflare (1.1.1.1)")
        dns1="1.1.1.1" dns2="1.0.0.1" ;;
      "Google (8.8.8.8)")
        dns1="8.8.8.8" dns2="8.8.4.4" ;;
      "Quad9 (9.9.9.9)")
        dns1="9.9.9.9" dns2="149.112.112.112" ;;
      "Pi-hole local (192.168.1.4)")
        dns1="192.168.1.4" dns2="1.1.1.1" ;;
      "Cloudflare DoH (securisé)")
        dns1="1.1.1.2" dns2="1.0.0.2" ;;
      "AdGuard (bloqueur pubs)")
        dns1="94.140.14.14" dns2="94.140.15.15" ;;
      *) exit 1 ;;
    esac

    # Trouver l'interface active
    iface=$(nmcli -t -f DEVICE,STATE device | grep ":connected" | head -1 | cut -d: -f1)

    if [ -z "$iface" ]; then
      notify-send "DNS Switch" "Aucune interface réseau active" -u critical
      exit 1
    fi

    # Appliquer via resolvectl (immédiat, pas besoin de rebuild)
    resolvectl dns "$iface" "$dns1" "$dns2"

    # Vider le cache DNS
    resolvectl flush-caches

    notify-send "DNS Switch" "DNS changé : $dns1 / $dns2" -t 3000
  '')
]
