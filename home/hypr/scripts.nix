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
]
