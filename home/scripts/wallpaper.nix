{ pkgs }:
[
  (pkgs.writeShellScriptBin "set-wallpaper" ''
    if [ -n "$1" ]; then
      # Sauvegarder le chemin du wallpaper
      echo "$1" > ~/.wallpaper
      # Appliquer le wallpaper
      pkill swaybg 2>/dev/null
      swaybg -i "$1" -m fill &
    fi
  '')

  (pkgs.writeShellScriptBin "restore-wallpaper" ''
    if [ -f ~/.wallpaper ]; then
      pkill swaybg 2>/dev/null
      swaybg -i "$(cat ~/.wallpaper)" -m fill &
    else
      swaybg -c '#1e1e2e' &
    fi
  '')
]
