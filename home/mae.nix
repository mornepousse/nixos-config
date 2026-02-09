{ config, pkgs, inputs, ... }:

{
  home.username = "mae";
  home.homeDirectory = "/home/mae";

  home.packages = with pkgs; [
    mpv
    imv
    btop
    fastfetch
    tree
    psmisc  # Pour killall
    waypaper # Gestionnaire de wallpaper pour Wayland
    wdisplays # Gestionnaire graphique de disposition d'écrans (Wayland)
    wlr-randr # CLI pour gérer les écrans (Wayland)
    kanshi    # Daemon pour profils d'écrans automatiques
    cliphist  # Clipboard manager pour Hyprland
    
    # Script pour sauvegarder et restaurer le wallpaper
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
    
    # Script power menu (shutdown/reboot/logout)
    # Détection automatique du compositor actif (sway, hyprland, niri)
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
          elif pgrep -x niri >/dev/null; then
            niri msg action quit
          fi
          ;;
      esac
    '')
    
    # Applets système
    pavucontrol          # Contrôle audio graphique
    networkmanagerapplet # nm-applet pour le réseau WiFi
    
    # LazyVim dependencies
    git
    gcc
    ripgrep
    fd
    lazygit
  ];

  # Neovim avec LazyVim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Git config
  programs.git = {
    enable = true;
    settings = {
      user.name = "mae";
      user.email = "";
    };
  };

  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = import ./shell/aliases.nix;
    
    initContent = ''
      # ESP-IDF
      alias get_idf='. $HOME/esp/esp-idf/export.sh'
      
      # Fastfetch à l'ouverture du terminal
      fastfetch
    '';
  };

  # Fish shell
  programs.fish = {
    enable = true;
    shellAliases = import ./shell/aliases.nix;
    interactiveShellInit = ''
      # Fastfetch à l'ouverture du terminal
      fastfetch
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  # Config niri
  home.file.".config/niri/config.kdl".source = ./niri/config.kdl;

  # Config Sway
  home.file.".config/sway/config".source = ./sway/config;

  # Config Hyprland (structure modulaire)
  home.file.".config/hypr/hyprland.conf".source = ./hypr/hyprland.conf;
  home.file.".config/hypr/env.conf".source = ./hypr/env.conf;
  home.file.".config/hypr/monitors.conf".source = ./hypr/monitors.conf;
  home.file.".config/hypr/input.conf".source = ./hypr/input.conf;
  home.file.".config/hypr/gestures.conf".source = ./hypr/gestures.conf;
  home.file.".config/hypr/general.conf".source = ./hypr/general.conf;
  home.file.".config/hypr/decoration.conf".source = ./hypr/decoration.conf;
  home.file.".config/hypr/animations.conf".source = ./hypr/animations.conf;
  home.file.".config/hypr/layouts.conf".source = ./hypr/layouts.conf;
  home.file.".config/hypr/misc.conf".source = ./hypr/misc.conf;
  home.file.".config/hypr/startup.conf".source = ./hypr/startup.conf;
  home.file.".config/hypr/keybinds.conf".source = ./hypr/keybinds.conf;

  # Config waybar
  home.file.".config/waybar/config".source = ./waybar/config.json;
  home.file.".config/waybar/config-sway.json".source = ./waybar/config-sway.json;
  home.file.".config/waybar/config-hyprland.json".source = ./waybar/config-hyprland.json;
  home.file.".config/waybar/style.css".source = ./waybar/style.css;

  # Config fuzzel
  home.file.".config/fuzzel/fuzzel.ini".source = ./fuzzel/fuzzel.ini;

  # Kanshi - Profils d'écrans automatiques
  # Note: fonctionne avec Sway et Hyprland (détection automatique des outputs Wayland)
  services.kanshi = {
    enable = true;
    systemdTarget = "sway-session.target";  # Fonctionne aussi avec Hyprland
  };

  # Config kanshi (profils d'écrans)
  home.file.".config/kanshi/config".source = ./kanshi/config;

  # Mako (notifications)
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 8;
    };
  };

  # Curseur style KDE (Breeze)
  home.pointerCursor = {
    name = "breeze_cursors";
    package = pkgs.kdePackages.breeze;
    size = 24;
    gtk.enable = true;
  };

  # Waypaper config
  home.file.".config/waypaper/config.ini".text = ''
    [Settings]
    folder = ~/Pictures
    backend = swaybg
    fill = fill
  '';

  # Associations MIME pour ouverture fichiers avec bons programmes
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Navigateur web
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";

      # Images
      "image/jpeg" = "imv.desktop";
      "image/png" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";

      # Vidéos
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";

      # Audio
      "audio/mpeg" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
      "audio/ogg" = "mpv.desktop";

      # PDF
      "application/pdf" = "firefox.desktop";

      # Texte
      "text/plain" = "nvim.desktop";

      # Archives (Ark - extraction directe dans Dolphin)
      "application/zip" = "org.kde.ark.desktop";
      "application/x-tar" = "org.kde.ark.desktop";
      "application/x-7z-compressed" = "org.kde.ark.desktop";
      "application/x-rar" = "org.kde.ark.desktop";
      "application/gzip" = "org.kde.ark.desktop";

      # File manager
      "inode/directory" = "org.kde.dolphin.desktop";
    };
  };

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
