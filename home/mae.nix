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
    (pkgs.writeShellScriptBin "power-menu" ''
      choice=$(printf "󰐥 Éteindre\n󰜉 Redémarrer\n󰍃 Déconnexion" | fuzzel --dmenu -p "Power: ")
      case "$choice" in
        "󰐥 Éteindre") systemctl poweroff ;;
        "󰜉 Redémarrer") systemctl reboot ;;
        "󰍃 Déconnexion") niri msg action quit ;;
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

  # Config waybar
  home.file.".config/waybar/config".source = ./waybar/config.json;
  home.file.".config/waybar/style.css".source = ./waybar/style.css;

  # Config fuzzel
  home.file.".config/fuzzel/fuzzel.ini".source = ./fuzzel/fuzzel.ini;

  # Kanshi - gestion automatique des profils d'écrans
  services.kanshi = {
    enable = true;
    systemdTarget = "niri.service";  # Démarrer avec niri
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

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
