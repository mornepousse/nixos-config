{ pkgs }:
[
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
        hyprctl keyword monitor "eDP-1,preferred,auto,1"
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

    # Lire l'etat actuel (0=normal, 1=90, 2=180, 3=270)
    if [ -f "$STATE_FILE" ]; then
      CURRENT=$(cat "$STATE_FILE")
    else
      CURRENT=0
    fi

    # Passer a l'orientation suivante
    NEXT=$(( (CURRENT + 1) % 4 ))
    echo "$NEXT" > "$STATE_FILE"

    # Correspondance Hyprland transform :
    # 0 = normal, 1 = 90deg, 2 = 180deg, 3 = 270deg
    TRANSFORM=$NEXT

    # Appliquer la rotation de l'ecran (eDP-1 = ecran interne du X230t)
    hyprctl keyword monitor "eDP-1,preferred,auto,1,transform,$TRANSFORM"

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
]
