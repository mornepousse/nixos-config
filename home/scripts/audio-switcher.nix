{ pkgs }:
[
  (pkgs.writeShellScriptBin "audio-switcher" ''
    # Liste les sorties audio et permet de changer la sortie par défaut via fuzzel
    default_sink=$(${pkgs.pulseaudio}/bin/pactl get-default-sink)

    # Récupère les sinks disponibles : "nom\tdescription"
    sinks=$(${pkgs.pulseaudio}/bin/pactl -f json list sinks | ${pkgs.jq}/bin/jq -r '.[] | "\(.name)\t\(.description)"')

    # Affiche dans fuzzel avec la description (marque le défaut avec *)
    selection=$(echo "$sinks" | while IFS=$'\t' read -r name desc; do
      if [ "$name" = "$default_sink" ]; then
        echo "* $desc"
      else
        echo "  $desc"
      fi
    done | fuzzel --dmenu -p "Sortie audio: ")

    [ -z "$selection" ] && exit 0

    # Retire le marqueur * ou les espaces
    clean_desc=$(echo "$selection" | sed 's/^[* ] *//')

    # Trouve le nom du sink correspondant
    new_sink=$(echo "$sinks" | while IFS=$'\t' read -r name desc; do
      if [ "$desc" = "$clean_desc" ]; then
        echo "$name"
        break
      fi
    done)

    [ -z "$new_sink" ] && exit 1

    # Change la sortie par défaut
    ${pkgs.pulseaudio}/bin/pactl set-default-sink "$new_sink"

    # Déplace tous les streams en cours vers la nouvelle sortie
    ${pkgs.pulseaudio}/bin/pactl -f json list sink-inputs | ${pkgs.jq}/bin/jq -r '.[].index' | while read -r idx; do
      ${pkgs.pulseaudio}/bin/pactl move-sink-input "$idx" "$new_sink"
    done
  '')
]
