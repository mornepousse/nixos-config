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
    vlc

    # Outils système
    btop
    fastfetch
    tree
    psmisc        # killall

    # Wayland
    waypaper      # Gestionnaire de wallpaper
    matugen       # Génération de palette Material You depuis le wallpaper
    wdisplays     # Disposition d'écrans
    cliphist      # Clipboard manager (Hyprland)
    udiskie       # Auto-mount USB
    hyprpicker    # Color picker
    wf-recorder   # Enregistrement d'écran
    hyprsunset    # Filtre lumière bleue

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

    # Jeux
    # tetro-tui désactivé — hash instable (fetchFromGitHub sur main)
    # Réactiver avec un hash fixe après install
  ] ++ (import ./scripts { inherit pkgs; })
    ++ (import ./hypr/scripts.nix { inherit pkgs; });

  # ── Neovim (kickstart.nvim + Dvorak) ────────────────────────
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
      alias claude='nocorrect claude'

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
      scan_timeout = 100;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  # ── Alacritty terminal ──────────────────────────────────────
  programs.alacritty = {
    enable = true;
    settings = {
      # Importer les couleurs générées par matugen
      general.import = [ "~/.config/alacritty/colors.toml" ];

      # Font
      font.normal.family = "0xProto Nerd Font Mono";
      font.bold.family = "0xProto Nerd Font Mono";
      font.italic.family = "0xProto Nerd Font Mono";
      font.size = 12;

      # Window
      window.opacity = 0.92;
      window.padding = { x = 12; y = 10; };
      window.decorations = "None";
      window.dynamic_padding = true;
      window.startup_mode = "Maximized";

      # Scrolling
      scrolling.history = 10000;

      # Cursor
      cursor.style.shape = "Beam";
      cursor.style.blinking = "On";
      cursor.blink_interval = 500;

      # Selection
      selection.save_to_clipboard = true;

      # Env
      env.TERM = "xterm-256color";

      # Keybindings
      keyboard.bindings = [
        { key = "Return"; mods = "Shift"; chars = "\\u000a"; }  # Shift+Enter = newline (pour claude-code)
      ];
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
        kb_variant = ${if hostname == "x230t" then "" else "altgr-intl"}
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
  home.file.".config/hypr/windowrules.conf".source = ./hypr/windowrules.conf;
  home.file.".config/hypr/hypridle.conf".source = ./hypr/hypridle.conf;
  home.file.".config/hypr/hyprlock.conf".source = ./hypr/hyprlock.conf;
  home.file.".config/hypr/tablet.conf".source = ./hypr/tablet.conf;

  # Waybar
  home.file.".config/waybar/config".source = ./waybar/config.json;
  home.file.".config/waybar/config-sway.json".source = ./waybar/config-sway.json;
  home.file.".config/waybar/config-hyprland.json".source = ./waybar/config-hyprland.json;
  home.file.".config/waybar/style.css".source = ./waybar/style.css;

  # Fuzzel (lanceur)
  # fuzzel.ini est géré dynamiquement par matugen (couleurs du wallpaper)
  # Le fichier statique de fallback reste dans home/fuzzel/fuzzel.ini
  # mais n'est PAS symlinké par Home Manager (matugen en prend le contrôle)

  # ── matugen — Material You color generation ─────────────────
  # Config et templates : matugen génère les couleurs depuis le wallpaper
  # Les fichiers de sortie (~/.config/hypr/colors.conf, fuzzel.ini, mako/config,
  # waybar/colors.css) sont écrits par le script set-wallpaper / restore-wallpaper
  home.file.".config/matugen/config.toml".source        = ./matugen/config.toml;
  home.file.".config/matugen/templates/hyprland-colors.conf".source = ./matugen/templates/hyprland-colors.conf;
  home.file.".config/matugen/templates/waybar-colors.css".source    = ./matugen/templates/waybar-colors.css;
  home.file.".config/matugen/templates/fuzzel.ini".source           = ./matugen/templates/fuzzel.ini;
  home.file.".config/matugen/templates/mako.ini".source             = ./matugen/templates/mako.ini;
  home.file.".config/matugen/templates/alacritty.toml".source       = ./matugen/templates/alacritty.toml;
  home.file.".config/matugen/templates/ghostty.conf".source         = ./matugen/templates/ghostty.conf;

  # ── Ghostty terminal ──────────────────────────────────────
  home.file.".config/ghostty/config".text = ''
    font-family = 0xProto Nerd Font Mono
    font-size = 12
    window-padding-x = 12
    window-padding-y = 10
    window-decoration = false
    background-opacity = 0.92
    cursor-style = bar
    cursor-style-blink = true
    copy-on-select = clipboard
    scrollback-limit = 10000
    window-inherit-working-directory = false
    working-directory = home
    config-file = ~/.config/ghostty/colors
  '';

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
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ];

  # ── Services utilisateur ────────────────────────────────────
  # Mako (notifications Wayland)
  # Les couleurs sont gérées dynamiquement par matugen via ~/.config/mako/config
  # matugen régénère ce fichier à chaque changement de wallpaper
  services.mako.enable = true;

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

  # Thunar - Open in Terminal avec ghostty
  home.file.".config/xfce4/helpers.rc".text = ''
    TerminalEmulator=alacritty
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
  # Couleurs Hyprland de fallback (utilisées avant le premier matugen)
  # Ce fichier est écrasé par matugen à chaque set-wallpaper / restore-wallpaper
  # Les couleurs par défaut sont inspirées de Catppuccin Mocha pour cohérence
  home.activation.createHyprlandColorsFallback = config.lib.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ~/.config/hypr
    if [ ! -f ~/.config/hypr/colors.conf ]; then
      cat > ~/.config/hypr/colors.conf << 'EOF'
# Couleurs Hyprland — fallback par défaut (Catppuccin Mocha)
# Sera remplacé par matugen au premier set-wallpaper / restore-wallpaper

$active_border_color   = rgb(cba6f7)
$inactive_border_color = rgb(45475a)
$background            = rgb(1e1e2e)
$surface               = rgb(181825)
$on_surface            = rgb(cdd6f4)
$primary               = rgb(cba6f7)
$on_primary            = rgb(1e1e2e)
$primary_container     = rgb(313244)
$secondary             = rgb(89b4fa)
$secondary_container   = rgb(45475a)
$tertiary              = rgb(f5c2e7)
$error                 = rgb(f38ba8)
EOF
    fi
  '';

  # Fichiers de fallback fuzzel et mako (avant premier matugen)
  home.activation.createMatugenFallbacks = config.lib.dag.entryAfter ["writeBoundary"] ''
    # Fuzzel — fallback si matugen n'a pas encore tourné
    mkdir -p ~/.config/fuzzel
    if [ ! -f ~/.config/fuzzel/fuzzel.ini ]; then
      cat > ~/.config/fuzzel/fuzzel.ini << 'EOF'
[main]
font=JetBrainsMono Nerd Font:size=16
prompt="󰍉  "
icon-theme=Papirus-Dark
layer=overlay
horizontal-pad=20
vertical-pad=15
inner-pad=10

[colors]
background=1e1e2edd
text=cdd6f4ff
match=cba6f7ff
selection=313244ff
selection-text=cdd6f4ff
selection-match=cba6f7ff
border=cba6f7ff

[border]
width=2
radius=12
EOF
    fi

    # Mako — fallback si matugen n'a pas encore tourné
    mkdir -p ~/.config/mako
    if [ ! -f ~/.config/mako/config ]; then
      cat > ~/.config/mako/config << 'EOF'
default-timeout=5000
border-radius=8
background-color=#1e1e2e
text-color=#cdd6f4
border-color=#cba6f7
progress-color=over #313244

[urgency=high]
border-color=#f38ba8
default-timeout=0
EOF
    fi

    # Waybar colors.css — fallback si matugen n'a pas encore tourné
    mkdir -p ~/.config/waybar
    if [ ! -f ~/.config/waybar/colors.css ]; then
      cat > ~/.config/waybar/colors.css << 'EOF'
/* Couleurs waybar — fallback Catppuccin Mocha */
@define-color background              #1e1e2e;
@define-color surface                  #181825;
@define-color surface_variant          #45475a;
@define-color surface_container        #313244;
@define-color surface_container_high   #45475a;
@define-color on_surface               #cdd6f4;
@define-color on_surface_variant       #bac2de;
@define-color primary                  #cba6f7;
@define-color on_primary               #1e1e2e;
@define-color primary_container        #313244;
@define-color on_primary_container     #cdd6f4;
@define-color secondary                #89b4fa;
@define-color on_secondary             #1e1e2e;
@define-color secondary_container      #45475a;
@define-color on_secondary_container   #cdd6f4;
@define-color tertiary                 #f5c2e7;
@define-color tertiary_container       #45475a;
@define-color on_tertiary_container    #cdd6f4;
@define-color error                    #f38ba8;
@define-color error_container          #93000a;
@define-color outline                  #6c7086;
@define-color outline_variant          #45475a;
EOF
    fi

    # Alacritty colors — fallback si matugen n'a pas encore tourné
    mkdir -p ~/.config/alacritty
    if [ ! -f ~/.config/alacritty/colors.toml ]; then
      cat > ~/.config/alacritty/colors.toml << 'EOF'
[colors.primary]
background = "#1e1e2e"
foreground = "#cdd6f4"
[colors.cursor]
text   = "#1e1e2e"
cursor = "#cba6f7"
[colors.selection]
text       = "#cdd6f4"
background = "#313244"
[colors.normal]
black   = "#1e1e2e"
red     = "#f38ba8"
green   = "#a6e3a1"
yellow  = "#f9e2af"
blue    = "#89b4fa"
magenta = "#cba6f7"
cyan    = "#94e2d5"
white   = "#cdd6f4"
[colors.bright]
black   = "#6c7086"
red     = "#f38ba8"
green   = "#a6e3a1"
yellow  = "#f9e2af"
blue    = "#89b4fa"
magenta = "#cba6f7"
cyan    = "#94e2d5"
white   = "#cdd6f4"
EOF
    fi
  '';

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
      "text/html" = "vivaldi-stable.desktop";
      "x-scheme-handler/http" = "vivaldi-stable.desktop";
      "x-scheme-handler/https" = "vivaldi-stable.desktop";

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
      "application/pdf" = "vivaldi-stable.desktop";

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
