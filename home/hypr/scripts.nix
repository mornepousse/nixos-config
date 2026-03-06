{ pkgs }:
[
  # Alt+Tab — focus la fenetre selectionnee (change de workspace/ecran)
  (pkgs.writeShellScriptBin "window-switcher" ''
    selected=$(hyprctl clients -j | ${pkgs.jq}/bin/jq -r '.[] | select(.mapped == true) | "\(.address) [\(.workspace.name)] \(.class) — \(.title)"' | fuzzel --dmenu -p "Fenetre: ")
    [ -z "$selected" ] && exit 0
    addr=$(echo "$selected" | cut -d' ' -f1)
    hyprctl dispatch focuswindow address:$addr
  '')

  # Ramene une fenetre sur le workspace actif
  (pkgs.writeShellScriptBin "window-bring" ''
    selected=$(hyprctl clients -j | ${pkgs.jq}/bin/jq -r '.[] | select(.mapped == true) | "\(.address) [\(.workspace.name)] \(.class) — \(.title)"' | fuzzel --dmenu -p "Ramener: ")
    [ -z "$selected" ] && exit 0
    addr=$(echo "$selected" | cut -d' ' -f1)
    hyprctl dispatch movetoworkspace e+0,address:$addr
    hyprctl dispatch focuswindow address:$addr
  '')

  (pkgs.writeShellScriptBin "hypr-internal-monitor" ''
    hyprctl monitors | sed -n 's/^Monitor \(eDP-[0-9]\+\|LVDS-[0-9]\+\|DSI-[0-9]\+\).*/\1/p' | head -n1
  '')

  (pkgs.writeShellScriptBin "monitor-toggle" ''
    choice=$(printf "💻 Laptop seul\n🖥️ Bureau (côte à côte)\n📺 Docked (vertical)" | fuzzel --dmenu -p "Profil écran: ")
    case "$choice" in
      "💻 Laptop seul")
        hyprctl keyword monitor "DVI-I-1,disable"
        hyprctl keyword monitor "DVI-I-2,disable"
        hyprctl keyword monitor "eDP-1,preferred,auto,1"
        ;;
      "🖥️ Bureau (côte à côte)")
        hyprctl keyword monitor "eDP-1,disable"
        hyprctl keyword monitor "DVI-I-1,1920x1080@60,0x0,1"
        hyprctl keyword monitor "DVI-I-2,1920x1080@60,1920x0,1"
        ;;
      "📺 Docked (vertical)")
        hyprctl keyword monitor "eDP-1,disable"
        hyprctl keyword monitor "DP-3,1920x1080@60,0x0,1,transform,2"
        hyprctl keyword monitor "DP-4,1920x1080@60,0x1080,1"
        ;;
    esac
  '')

  # Script de rotation ecran pour le X230t (mode tablette)
  # Cycle : normal -> 90 (droite) -> 180 (inverse) -> 270 (gauche) -> normal
  # Fait tourner l'ecran ET les peripheriques d'entree (Wacom, tactile)
  (pkgs.writeShellScriptBin "rotate-screen" ''
    STATE_FILE="/tmp/hypr-rotation-state"
    INTERNAL_MONITOR="$(hypr-internal-monitor)"

    if [ -z "$INTERNAL_MONITOR" ]; then
      notify-send -u critical -t 2500 "Rotation ecran" "Ecran interne introuvable"
      exit 1
    fi

    # Lire l'etat actuel (0=normal, 1=90, 2=180, 3=270)
    if [ -f "$STATE_FILE" ]; then
      CURRENT=$(cat "$STATE_FILE")
    else
      CURRENT=0
    fi

    case "$CURRENT" in
      0|1|2|3) ;;
      *) CURRENT=0 ;;
    esac

    # Passer a l'orientation suivante
    NEXT=$(( (CURRENT + 1) % 4 ))
    echo "$NEXT" > "$STATE_FILE"

    # Correspondance Hyprland transform :
    # 0 = normal, 1 = 90deg, 2 = 180deg, 3 = 270deg
    TRANSFORM=$NEXT

    # Appliquer la rotation de l'ecran interne du X230t
    if ! hyprctl keyword monitor "$INTERNAL_MONITOR,preferred,auto,1,transform,$TRANSFORM" >/dev/null; then
      notify-send -u critical -t 2500 "Rotation ecran" "Echec rotation sur $INTERNAL_MONITOR"
      exit 1
    fi

    # Faire tourner les peripheriques d'entree Wacom/tactile pour correspondre
    # Hyprland gere la rotation des inputs via la section device dans la config,
    # mais on peut aussi forcer via hyprctl pour les changements dynamiques
    case $NEXT in
      0)
        ORIENTATION="normal"
        NOTIFY="Normal (0)"
        ;;
      1)
        ORIENTATION="90"
        NOTIFY="Droite (90)"
        ;;
      2)
        ORIENTATION="180"
        NOTIFY="Inverse (180)"
        ;;
      3)
        ORIENTATION="270"
        NOTIFY="Gauche (270)"
        ;;
    esac

    # Rotation des inputs Wacom/tactile via hyprctl
    # On recupere les devices touch/tablet et on applique la matrice de transformation
    # Hyprland applique automatiquement la rotation des inputs quand le monitor est transforme

    notify-send -t 2000 "Rotation ecran" "$NOTIFY"
  '')

  # Script de secours : reinitialise l'ecran interne en orientation normale
  (pkgs.writeShellScriptBin "reset-internal-monitor" ''
    INTERNAL_MONITOR="$(hypr-internal-monitor)"

    if [ -z "$INTERNAL_MONITOR" ]; then
      notify-send -u critical -t 2500 "Ecran interne" "Aucun ecran interne detecte"
      exit 1
    fi

    if hyprctl keyword monitor "$INTERNAL_MONITOR,preferred,auto,1,transform,0" >/dev/null; then
      echo 0 > /tmp/hypr-rotation-state
      notify-send -t 1800 "Ecran interne" "$INTERNAL_MONITOR reinitialise"
    else
      notify-send -u critical -t 2500 "Ecran interne" "Echec reinitialisation $INTERNAL_MONITOR"
      exit 1
    fi
  '')

  # Script toggle clavier virtuel (squeekboard)
  (pkgs.writeShellScriptBin "toggle-vkbd" ''
    if pgrep -x squeekboard > /dev/null; then
      pkill squeekboard
      notify-send -t 1500 "Clavier virtuel" "Desactive"
    else
      # Lancer squeekboard en arriere-plan
      # WAYLAND_DISPLAY doit etre defini (normal sous Hyprland)
      squeekboard &
      disown
      notify-send -t 1500 "Clavier virtuel" "Active"
    fi
  '')

  # Script de monitoring mode tablette (fallback si switch events ne marchent pas)
  # Surveille hotkey_tablet_mode et déclenche rotation/reset
  (pkgs.writeShellScriptBin "tablet-mode-monitor" ''
    SYSFS="/sys/devices/platform/thinkpad_acpi/hotkey_tablet_mode"
    STATE_FILE="/tmp/tablet-mode-last"
    
    [ -r "$SYSFS" ] || { echo "Pas de fichier $SYSFS"; exit 1; }
    
    # Initialiser l'état
    cat "$SYSFS" > "$STATE_FILE" 2>/dev/null || echo 0 > "$STATE_FILE"
    
    echo "Démarrage monitoring mode tablette..."
    
    while true; do
      current=$(cat "$SYSFS" 2>/dev/null || echo 0)
      last=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
      
      if [ "$current" != "$last" ]; then
        echo "$current" > "$STATE_FILE"
        if [ "$current" = "1" ]; then
          echo "Mode tablette activé"
          rotate-screen
        else
          echo "Mode laptop activé"
          reset-internal-monitor
        fi
      fi
      
      sleep 1
    done
  '')
]
