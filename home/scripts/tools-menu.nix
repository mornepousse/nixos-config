{ pkgs }:
[
  (pkgs.writeShellScriptBin "tools-menu" ''
    choice=$(printf '%s\n' \
      "--- Audio / Reseau ---" \
      "Sortie audio" \
      "Volume" \
      "DNS" \
      "Wifi" \
      "Bluetooth" \
      "--- Affichage ---" \
      "Ecrans" \
      "Wallpaper + couleurs" \
      "Mode nuit" \
      "Mode gaming" \
      "Recharger waybar" \
      "--- Captures ---" \
      "Screenshot ecran" \
      "Screenshot zone" \
      "Screenshot zone (sauvegarder)" \
      "Enregistrer ecran" \
      "Enregistrer zone" \
      "Color picker" \
      "--- Systeme ---" \
      "Clipboard" \
      "Minuteur" \
      "Tuer une app" \
      "Verrouiller" \
      "Power" \
      | fuzzel --dmenu -p "Outils: ")

    [ -z "$choice" ] && exit 0

    sleep 0.1

    case "$choice" in
      # Audio / Reseau
      "Sortie audio")                   exec audio-switcher ;;
      "Volume")                         exec pavucontrol ;;
      "DNS")                            exec dns-switch ;;
      "Wifi")                           exec nm-connection-editor ;;
      "Bluetooth")                      exec blueman-manager ;;

      # Affichage
      "Ecrans")                         exec monitor-toggle ;;
      "Wallpaper + couleurs")           exec waypaper ;;
      "Mode nuit")
        if pgrep -x hyprsunset > /dev/null; then
          killall hyprsunset
          notify-send "Mode nuit desactive"
        else
          hyprsunset -t 4000 &
          notify-send "Mode nuit active (4000K)"
        fi ;;
      "Mode gaming")
        current=$(hyprctl getoption animations:enabled -j | ${pkgs.jq}/bin/jq '.int')
        if [ "$current" = "1" ]; then
          hyprctl --batch "keyword animations:enabled false ; keyword decoration:shadow:enabled false ; keyword general:gaps_in 0 ; keyword general:gaps_out 0 ; keyword decoration:blur:enabled false ; keyword general:border_size 1"
          notify-send "Mode gaming ON" "Animations et effets desactives"
        else
          hyprctl --batch "keyword animations:enabled true ; keyword decoration:shadow:enabled true ; keyword general:gaps_in 3 ; keyword general:gaps_out 8 ; keyword decoration:blur:enabled true ; keyword general:border_size 2"
          notify-send "Mode gaming OFF" "Animations et effets reactives"
        fi ;;
      "Recharger waybar")               pkill waybar; exec waybar -c ~/.config/waybar/config-hyprland.json -s ~/.config/waybar/style.css ;;

      # Captures
      "Screenshot ecran")               exec sh -c 'grim - | wl-copy && notify-send "Screenshot copie"' ;;
      "Screenshot zone")                exec sh -c 'grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot copie"' ;;
      "Screenshot zone (sauvegarder)")  exec sh -c 'mkdir -p ~/Pictures/screenshots && f=~/Pictures/screenshots/$(date +%Y%m%d-%H%M%S).png && grim -g "$(slurp)" "$f" && notify-send "Screenshot sauvegarde" "$f"' ;;
      "Enregistrer ecran")
        if pgrep -x wf-recorder > /dev/null; then
          killall -s SIGINT wf-recorder
          notify-send "Enregistrement arrete" "$(ls -t ~/Videos/screenrecord-*.mp4 2>/dev/null | head -1)"
        else
          mkdir -p ~/Videos
          f=~/Videos/screenrecord-$(date +%Y%m%d-%H%M%S).mp4
          wf-recorder -f "$f" &
          notify-send "Enregistrement demarre" "Relancer pour arreter"
        fi ;;
      "Enregistrer zone")
        if pgrep -x wf-recorder > /dev/null; then
          killall -s SIGINT wf-recorder
          notify-send "Enregistrement arrete" "$(ls -t ~/Videos/screenrecord-*.mp4 2>/dev/null | head -1)"
        else
          mkdir -p ~/Videos
          f=~/Videos/screenrecord-$(date +%Y%m%d-%H%M%S).mp4
          geometry=$(slurp)
          [ -n "$geometry" ] && wf-recorder -g "$geometry" -f "$f" &
          notify-send "Enregistrement demarre" "Relancer pour arreter"
        fi ;;
      "Color picker")                   exec sh -c 'color=$(hyprpicker -a) && notify-send "Couleur copiee" "$color"' ;;

      # Systeme
      "Clipboard")                      exec sh -c 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy' ;;
      "Minuteur")
        minutes=$(printf "1\n3\n5\n10\n15\n30\n45\n60" | fuzzel --dmenu -p "Minuteur (minutes): ")
        [ -z "$minutes" ] && exit 0
        notify-send "Minuteur" "$minutes min demarre"
        (sleep "''${minutes}m" && notify-send -u critical "Minuteur" "Les $minutes minutes sont ecoulees !") & ;;
      "Tuer une app")                   exec sh -c 'hyprctl kill' ;;
      "Verrouiller")                    exec loginctl lock-session ;;
      "Power")                          exec power-menu ;;
    esac
  '')
]
