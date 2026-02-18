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
    # Détection automatique du compositor actif (sway, hyprland)
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
          fi
          ;;
      esac
    '')

    # Script pour basculer entre les profils d'écrans (Hyprland)
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
          hyprctl keyword monitor "DVI-I-2,1920x1080@60,0x0,1,transform,2"
          hyprctl keyword monitor "DVI-I-1,1920x1080@60,0x1080,1"
          ;;
      esac
    '')

    # Script helper pour initialiser un projet Slint rapidement
    (pkgs.writeShellScriptBin "new-slint-project" ''
if [ -z "$1" ]; then
  echo "Usage: new-slint-project <nom-du-projet>"
  exit 1
fi

PROJECT_NAME="$1"

cargo init "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit 1

cargo add slint

mkdir -p ui
cat > ui/app.slint << 'SLINT'
import { VerticalBox, Button, LineEdit } from "std-widgets.slint";

export component App inherits Window {
    title: "Mon App Slint";
    preferred-width: 600px;
    preferred-height: 400px;

    VerticalBox {
        Text {
            text: "Hello depuis Slint + Rust !";
            font-size: 24px;
            horizontal-alignment: center;
        }
        Button {
            text: "Cliquer ici";
            clicked => { debug("Bouton cliqué !"); }
        }
    }
}
SLINT

cat > src/main.rs << 'RUST'
slint::include_modules!();

fn main() {
    let app = App::new().unwrap();
    app.run().unwrap();
}
RUST

cat > build.rs << 'RUST'
fn main() {
    slint_build::compile("ui/app.slint").unwrap();
}
RUST

cargo add slint-build --build

echo ""
echo "Projet '$PROJECT_NAME' cree avec succes !"
echo ""
echo "Commandes utiles :"
echo "  cd $PROJECT_NAME"
echo "  cargo run                    # Lancer l'app"
echo "  slint-viewer ui/app.slint    # Preview live de l'UI"
echo "  cargo watch -x run           # Recompiler auto"
    '')

    # Script helper pour initialiser un projet Qt Quick (QML + C)
    (pkgs.writeShellScriptBin "new-qt-project" ''
if [ -z "$1" ]; then
  echo "Usage: new-qt-project <nom-du-projet>"
  exit 1
fi

PROJECT_NAME="$1"

mkdir -p "$PROJECT_NAME/ui"
mkdir -p "$PROJECT_NAME/src"
cd "$PROJECT_NAME" || exit 1

cat > CMakeLists.txt << 'CMAKE'
cmake_minimum_required(VERSION 3.20)
project(app LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Widgets SerialPort)
qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

qt_add_executable(app src/main.cpp)

qt_add_qml_module(app
    URI App
    VERSION 1.0
    QML_FILES ui/Main.qml
)

target_link_libraries(app PRIVATE
    Qt6::Quick
    Qt6::Widgets
    Qt6::SerialPort
)
CMAKE

cat > src/main.cpp << 'CPP'
#include <QApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    using namespace Qt::StringLiterals;
    const QUrl url(u"qrc:/qt/qml/App/ui/Main.qml"_s);
    engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
CPP

cat > ui/Main.qml << 'QML'
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 600
    height: 400
    title: "Mon App Qt Quick"

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "Hello depuis Qt Quick !"
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
        }

        Button {
            text: "Cliquer ici"
            Layout.alignment: Qt.AlignHCenter
            onClicked: console.log("Bouton clique !")
        }
    }
}
QML

cat > .clangd << 'CLANGD'
# Configuration clangd pour projets Qt6
CompileFlags:
  Add:
    - -fPIC
    - -Wno-unknown-warning-option
  Remove:
    # Désactiver les warnings Qt (macros, MOC, etc.)
    - -Wsuggest-override
    - -Woverloaded-virtual
InlayHints:
  DeducedTypes: true
  Designators: true
  BlockEnd: false
CLANGD

# Qt Creator .pro: configuration de Qt Creator
cat > "''${PROJECT_NAME}.pro" << 'QTPRO'
# Fichier Qt Creator pour reconnaissance du projet
TEMPLATE = app
QT += quick widgets serialport
LANGUAGE = C++17
CONFIG += c++17
SOURCES += src/main.cpp
QML_FILES += ui/Main.qml
QTPRO

mkdir -p build

# Créer un script de build qui copie compile_commands.json à la racine (pour clangd/Neovim)
cat > build.sh << 'BUILDSCRIPT'
#!/bin/bash
set -e
echo "Configuration CMake..."
cmake -B build -G Ninja
echo "Compilation..."
ninja -C build
echo "Copie compile_commands.json à la racine pour clangd/Neovim..."
cp build/compile_commands.json .
echo "✓ Compilation reussie !"
BUILDSCRIPT
chmod +x build.sh

echo ""
echo "Projet '$PROJECT_NAME' cree avec succes !"
echo ""
echo "Commandes utiles :"
echo "  cd $PROJECT_NAME"
echo "  qtcreator .                                    # Ouvrir dans Qt Creator"
echo "  ./build.sh                                     # Compiler (et configurer clangd)"
echo "  ./build/app                                    # Lancer"
echo "  qml ui/Main.qml                               # Preview live QML"
echo ""
echo "✓ Configuration Qt Creator, .clangd et build.sh generes"
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

    # Script pour configurer rclone avec Synology NAS
    (pkgs.writeShellScriptBin "setup-rclone-nas" ''
      mkdir -p ~/.config/rclone

      # Créer la config rclone pour Synology
      cat > ~/.config/rclone/rclone.conf << 'EOF'
[nas]
type = smb
host = 192.168.1.11
user = mae
pass = ''${RCLONE_SMB_PASS:-}
domain =
EOF

      # Demander le password s'il n'est pas défini
      if [ -z "$RCLONE_SMB_PASS" ]; then
        read -sp "Entrez le password SMB pour mae: " PASS
        echo ""
        sed -i "s|pass = |pass = $PASS|" ~/.config/rclone/rclone.conf
      fi

      chmod 600 ~/.config/rclone/rclone.conf
      echo "✓ Config rclone créée dans ~/.config/rclone/rclone.conf"
      echo ""
      echo "Montage: rclone mount nas:/FULLACCESS ~/mnt/nas/fullaccess --daemon"
      echo "Démont: fusermount -u ~/mnt/nas/fullaccess"
    '')

    # Script pour monter le NAS Synology via GVFS
    (pkgs.writeShellScriptBin "mount-nas" ''
      mkdir -p $HOME/mnt/nas
      ${glib}/bin/gio mount smb://mae@192.168.1.11/FULLACCESS
      sleep 1
      rm -f $HOME/mnt/nas/fullaccess 2>/dev/null
      ln -sf '/run/user/1000/gvfs/smb-share:server=192.168.1.11,share=fullaccess,user=mae' $HOME/mnt/nas/fullaccess
      echo "✓ NAS monté sur $HOME/mnt/nas/fullaccess"
    '')
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
