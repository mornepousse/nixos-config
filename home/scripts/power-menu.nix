{ pkgs }:
[
  (pkgs.writeShellScriptBin "power-menu" ''
    choice=$(printf "󰐥 Éteindre\n󰜉 Redémarrer\n󰍃 Déconnexion" | fuzzel --dmenu -p "Power: ")
    case "$choice" in
      "󰐥 Éteindre") systemctl poweroff ;;
      "󰜉 Redémarrer") systemctl reboot ;;
      "󰍃 Déconnexion")
        # Détection du compositor actif
        if pgrep -x sway >/dev/null; then
          swaymsg exit
        elif pgrep -x Hyprland >/dev/null; then
          hyprctl dispatch exit
        fi
        ;;
    esac
  '')
]
