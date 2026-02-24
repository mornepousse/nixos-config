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
    cliphist  # Clipboard manager pour Hyprland

    # Thèmes Catppuccin (dark mode)
    catppuccin-gtk
    catppuccin-qt5ct

    # Applets système
    pavucontrol          # Contrôle audio graphique
    networkmanagerapplet # nm-applet pour le réseau WiFi

    # LazyVim dependencies
    git
    gcc
    ripgrep
    fd
    lazygit
  ] ++ (import ./scripts { inherit pkgs; })
    ++ (import ./hypr/scripts.nix { inherit pkgs; });

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

    history = {
      size = 10000;
      save = 10000;
      ignoreAllDups = true;
      ignoreSpace = true;
    };

    initContent = ''
      # Lancement automatique de Hyprland sur TTY1
      if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi

      # Completion options
      setopt COMPLETE_IN_WORD
      setopt ALWAYS_TO_END
      setopt AUTO_MENU
      setopt MENU_COMPLETE

      # History options
      setopt HIST_FIND_NO_DUPS
      setopt HIST_IGNORE_DUPS
      setopt SHARE_HISTORY
      setopt APPEND_HISTORY

      # Directory options
      setopt AUTO_CD
      setopt PUSHD_IGNORE_DUPS
      setopt CORRECT
      setopt CORRECT_ALL

      # Key bindings (emacs-like)
      bindkey "^A" beginning-of-line
      bindkey "^E" end-of-line
      bindkey "^R" history-incremental-search-backward
      bindkey "^S" history-incremental-search-forward
      bindkey "^[[3~" delete-char
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      # ESP-IDF
      #alias get_idf='. $HOME/esp/esp-idf/export.sh'
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

  # Kitty Terminal
  programs.kitty = {
    enable = true;
    settings = {
      # Ne pas demander confirmation à la fermeture
      confirm_os_window_close = 0;

      # Appearance
      font_family = "JetBrains Mono";
      font_size = 12;
      background_opacity = 0.95;

      # Colors (Catppuccin Mocha)
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      cursor = "#f5e0dc";

      # Scrollback
      scrollback_lines = 10000;

      # Copy/Paste
      copy_on_select = "clipboard";
      strip_trailing_spaces = "smart";

      # Window
      window_padding_width = 10;
      hide_window_decorations = "no";

      # Tab bar
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      active_tab_foreground = "#1e1e2e";
      active_tab_background = "#a6e3a1";
      inactive_tab_foreground = "#cdd6f4";
      inactive_tab_background = "#313244";
    };
  };

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

  # GTK Theme - Catppuccin Mocha (dark mode)
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha";
      package = pkgs.catppuccin-gtk;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Qt Theme - Forcer le dark mode
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  # GNOME dconf settings - Dark mode pour toutes les apps GTK
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Catppuccin-Mocha";
      icon-theme = "Papirus-Dark";
    };

    # Nemo file manager preferences
    "org/nemo/preferences" = {
      show-hidden-files = true;
      show-location-entry = true;
      sort-directories-first = true;
    };

    "org/nemo/desktop" = {
      show-desktop-icons = false;
    };
  };

  # Variables d'environnement pour dark mode
  home.sessionVariables = {
    GTK_THEME = "Catppuccin-Mocha";
    QT_QPA_PLATFORMTHEME = "gtk3";
  };

  # Mako (notifications)
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 8;
    };
  };

  # Polkit GNOME authentication agent (popup mot de passe GUI)
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = [ "hyprland-session.target" ];
      After = [ "hyprland-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
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

  # Fichiers .desktop pour applications sans desktop file natif
  home.file.".local/share/applications/mpv.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=mpv Media Player
    Comment=Play videos and music
    Icon=mpv
    Exec=mpv %U
    Terminal=false
    Categories=AudioVideo;Audio;Video;Player;
    MimeType=video/mp4;video/x-matroska;video/webm;video/mpeg;audio/mpeg;audio/flac;audio/ogg;audio/mp3;
  '';

  home.file.".local/share/applications/imv.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=imv Image Viewer
    Comment=Fast image viewer for Wayland
    Icon=image-viewer
    Exec=imv %U
    Terminal=false
    Categories=Graphics;Viewer;
    MimeType=image/jpeg;image/png;image/gif;image/webp;image/bmp;image/tiff;
  '';

  home.file.".local/share/applications/alacritty.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Alacritty
    Comment=Fast GPU-accelerated terminal emulator
    Icon=Alacritty
    Exec=alacritty
    Terminal=false
    Categories=System;TerminalEmulator;
  '';

  # XDG user directories
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # Activation script pour créer le fichier credentials avec permissions sécurisées
  # Le fichier réel ne doit PAS être tracké dans git!
  home.activation.createSmbCredentials = config.lib.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ~/.config
    if [ ! -f ~/.smbcredentials ]; then
      cat > ~/.smbcredentials << 'EOF'
# Créer ce fichier manuellement avec vos credentials SMB
# Format:
# username=<user>
# password=<pass>
# domain=<domain>
EOF
      chmod 600 ~/.smbcredentials
      echo "Fichier ~/.smbcredentials créé. Complétez-le avec vos credentials!"
    fi
  '';

  # Entrées .desktop pour les applications (pour fuzzel et launchers)
  xdg.desktopEntries = {
    qtcreator = {
      name = "Qt Creator";
      exec = "qtcreator %F";
      icon = "qtcreator";
      type = "Application";
      categories = [ "Development" "IDE" ];
      comment = "Qt Creator - IDE pour Qt6";
    };
  };

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

      # Archives (file-roller - extraction directe dans Nemo)
      "application/zip" = "file-roller.desktop";
      "application/x-tar" = "file-roller.desktop";
      "application/x-7z-compressed" = "file-roller.desktop";
      "application/x-rar" = "file-roller.desktop";
      "application/gzip" = "file-roller.desktop";

      # File manager
      "inode/directory" = "nemo.desktop";
    };
  };

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
