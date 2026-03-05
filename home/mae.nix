{ config, pkgs, inputs, hostname, ... }:

{
  # ══════════════════════════════════════════════════════════════
  #  Home Manager — Configuration utilisateur mae
  # ══════════════════════════════════════════════════════════════

  home.username = "mae";
  home.homeDirectory = "/home/mae";

  # ── Packages utilisateur ────────────────────────────────────
  home.packages = with pkgs; [
    # Multimédia
    mpv
    imv

    # Outils système
    btop
    fastfetch
    tree
    psmisc        # killall

    # Wayland
    waypaper      # Gestionnaire de wallpaper
    wdisplays     # Disposition d'écrans
    cliphist      # Clipboard manager (Hyprland)

    # Thèmes Catppuccin (dark mode)
    catppuccin-gtk
    catppuccin-qt5ct

    # Applets système
    pavucontrol          # Contrôle audio
    networkmanagerapplet # WiFi (nm-applet)
    polkit_gnome         # Authentification GUI

    # LazyVim — dépendances runtime
    git
    gcc
    ripgrep
    fd
    lazygit
  ] ++ (import ./scripts { inherit pkgs; })
    ++ (import ./hypr/scripts.nix { inherit pkgs; });

  # ── Neovim (LazyVim) ────────────────────────────────────────
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # ── Git ──────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user.name = "mae";
      user.email = "";
    };
  };

  # ── Zsh ──────────────────────────────────────────────────────
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

  # ── Fish ─────────────────────────────────────────────────────
  programs.fish = {
    enable = true;
    shellAliases = import ./shell/aliases.nix;
    interactiveShellInit = ''
      # Fastfetch à l'ouverture du terminal
      fastfetch
    '';
  };

  # ── Starship prompt ─────────────────────────────────────────
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

  # ── Kitty terminal ──────────────────────────────────────────
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

  # ── Dotfiles Wayland ────────────────────────────────────────
  # Sway
  home.file.".config/sway/config".source = ./sway/config;

  # Hyprland (structure modulaire)
  home.file.".config/hypr/hyprland.conf".source = ./hypr/hyprland.conf;
  home.file.".config/hypr/env.conf".source = ./hypr/env.conf;
  home.file.".config/hypr/monitors.conf".source = ./hypr/monitors.conf;
  # input.conf généré dynamiquement (layout clavier selon la machine)
  home.file.".config/hypr/input.conf".text = ''
    # Input Configuration
    # Hyprland - NixOS (généré par mae.nix)

    input {
        kb_layout = ${if hostname == "x230t" then "fr" else "us"}
        numlock_by_default = true

        touchpad {
            tap-to-click = true
            natural_scroll = true
            disable_while_typing = true
        }

        follow_mouse = 1
        sensitivity = 0
    }
  '';
  home.file.".config/hypr/gestures.conf".source = ./hypr/gestures.conf;
  home.file.".config/hypr/general.conf".source = ./hypr/general.conf;
  home.file.".config/hypr/decoration.conf".source = ./hypr/decoration.conf;
  home.file.".config/hypr/animations.conf".source = ./hypr/animations.conf;
  home.file.".config/hypr/layouts.conf".source = ./hypr/layouts.conf;
  home.file.".config/hypr/misc.conf".source = ./hypr/misc.conf;
  home.file.".config/hypr/startup.conf".source = ./hypr/startup.conf;
  home.file.".config/hypr/keybinds.conf".source = ./hypr/keybinds.conf;
  home.file.".config/hypr/tablet.conf".source = ./hypr/tablet.conf;

  # Waybar
  home.file.".config/waybar/config".source = ./waybar/config.json;
  home.file.".config/waybar/config-sway.json".source = ./waybar/config-sway.json;
  home.file.".config/waybar/config-hyprland.json".source = ./waybar/config-hyprland.json;
  home.file.".config/waybar/style.css".source = ./waybar/style.css;

  # Fuzzel (lanceur)
  home.file.".config/fuzzel/fuzzel.ini".source = ./fuzzel/fuzzel.ini;

  # ── Thèmes & Apparence ──────────────────────────────────────
  # GTK — Catppuccin Mocha (dark mode)
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

  # Qt — dark mode via GTK
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  # dconf — dark mode + Thunar prefs
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Catppuccin-Mocha";
      icon-theme = "Papirus-Dark";
    };

    # Thunar file manager preferences
    "org/xfce/thunar" = {
      misc-show-hidden = true;
      misc-sort-folders-first = true;
    };
  };

  # Variables de session (dark mode global)
  home.sessionVariables = {
    GTK_THEME = "Catppuccin-Mocha";
    QT_QPA_PLATFORMTHEME = "gtk3";
  };

  # ── Services utilisateur ────────────────────────────────────
  # Mako (notifications Wayland)
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 8;
    };
  };

  # Polkit GNOME — popup mot de passe GUI
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # ── Curseur ──────────────────────────────────────────────────
  home.pointerCursor = {
    name = "breeze_cursors";
    package = pkgs.kdePackages.breeze;
    size = 24;
    gtk.enable = true;
  };

  # ── Configs diverses ────────────────────────────────────────
  # Waypaper
  home.file.".config/waypaper/config.ini".text = ''
    [Settings]
    folder = ~/Pictures
    backend = swaybg
    fill = fill
  '';

  # Thunar - Open in Terminal avec kitty
  home.file.".config/xfce4/helpers.rc".text = ''
    TerminalEmulator=kitty
  '';

  # ── Fichiers .desktop ───────────────────────────────────────
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

  # ── XDG ──────────────────────────────────────────────────────
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # ── Activation scripts ──────────────────────────────────────
  # Credentials SMB (créé au premier deploy si absent)
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

  # ── Associations MIME ───────────────────────────────────────
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

      # Archives (file-roller via thunar-archive-plugin)
      "application/zip" = "file-roller.desktop";
      "application/x-tar" = "file-roller.desktop";
      "application/x-7z-compressed" = "file-roller.desktop";
      "application/x-rar" = "file-roller.desktop";
      "application/gzip" = "file-roller.desktop";

      # File manager
      "inode/directory" = "thunar.desktop";
    };
  };

  # ══════════════════════════════════════════════════════════════
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
