{ pkgs }:
[
  (pkgs.writeShellScriptBin "set-wallpaper" ''
    if [ -z "$1" ]; then
      echo "Usage: set-wallpaper <chemin-image>"
      exit 1
    fi

    if [ ! -f "$1" ]; then
      echo "Erreur: fichier introuvable: $1"
      exit 1
    fi

    # Sauvegarder le chemin du wallpaper
    echo "$1" > ~/.wallpaper

    # Générer la palette Material You depuis l'image (synchrone)
    # matugen écrit dans :
    #   ~/.config/hypr/colors.conf      → variables Hyprland
    #   ~/.config/waybar/colors.css     → variables CSS pour waybar
    #   ~/.config/fuzzel/fuzzel.ini     → config fuzzel complète
    #   ~/.config/mako/config           → config mako complète
    ${pkgs.matugen}/bin/matugen \
      --config ~/.config/matugen/config.toml \
      image "$1"

    # Appliquer le wallpaper
    pkill swaybg 2>/dev/null || true
    ${pkgs.swaybg}/bin/swaybg -i "$1" -m fill &

    # Recharger Hyprland (relit colors.conf avec les nouvelles variables)
    hyprctl reload >/dev/null 2>&1 || true

    # Relancer waybar avec les nouvelles couleurs CSS
    pkill waybar 2>/dev/null || true
    waybar -c ~/.config/waybar/config-hyprland.json \
           -s ~/.config/waybar/style.css \
           >/dev/null 2>&1 &

    # Recharger mako avec la nouvelle config
    makoctl reload 2>/dev/null || true
  '')

  # restore-wallpaper : utilisé au boot (exec-once dans startup.conf)
  # Appelle matugen de façon SYNCHRONE, puis lance waybar et mako.
  # C'est restore-wallpaper qui est responsable du lancement initial de waybar/mako
  # afin de garantir qu'ils démarrent APRÈS la génération des couleurs.
  # startup.conf ne doit donc PAS lancer waybar et mako séparément.
  (pkgs.writeShellScriptBin "restore-wallpaper" ''
    if [ -f ~/.wallpaper ]; then
      WALLPAPER="$(cat ~/.wallpaper)"

      if [ -f "$WALLPAPER" ]; then
        # Régénérer les couleurs depuis le wallpaper sauvegardé (synchrone)
        ${pkgs.matugen}/bin/matugen \
          --config ~/.config/matugen/config.toml \
          image "$WALLPAPER"

        # Appliquer le wallpaper
        pkill swaybg 2>/dev/null || true
        ${pkgs.swaybg}/bin/swaybg -i "$WALLPAPER" -m fill &
      else
        # Fichier wallpaper introuvable — fond uni de fallback
        ${pkgs.swaybg}/bin/swaybg -c '#1e1e2e' &
      fi
    else
      # Pas de wallpaper sauvegardé — fond uni de fallback
      ${pkgs.swaybg}/bin/swaybg -c '#1e1e2e' &
    fi

    # Lancer mako avec la config fraîchement générée (ou le fallback)
    pkill mako 2>/dev/null || true
    mako &

    # Lancer waybar avec les couleurs fraîchement générées (ou le fallback)
    pkill waybar 2>/dev/null || true
    waybar -c ~/.config/waybar/config-hyprland.json \
           -s ~/.config/waybar/style.css \
           >/dev/null 2>&1 &
  '')
]
