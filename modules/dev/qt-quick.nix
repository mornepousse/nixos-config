{ config, pkgs, ... }:

let
  # Wrapper Qt Creator avec toutes les dépendances runtime (GSettings, DBus, portals)
  # Résout le crash "No GSettings schemas are installed on the system"
  # On utilise writeShellApplication pour un wrapper propre et sans conflit de symlinks
  qtcreator-wrapped = pkgs.writeShellApplication {
    name = "qtcreator";
    runtimeInputs = [ ];  # pas besoin, on appelle le binaire par chemin absolu
    text = ''
      # GSettings schemas (résout "No GSettings schemas are installed on the system")
      export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:${pkgs.adwaita-icon-theme}/share:/run/current-system/sw/share''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"

      # Backend dconf pour GSettings (lecture/écriture des settings)
      export GIO_EXTRA_MODULES="''${GIO_EXTRA_MODULES:+$GIO_EXTRA_MODULES:}${pkgs.dconf.lib}/lib/gio/modules"

      # Qt plugins (qtbase + qtwayland pour Wayland natif)
      export QT_PLUGIN_PATH="${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}:${pkgs.qt6.qtwayland}/${pkgs.qt6.qtbase.qtPluginPrefix}''${QT_PLUGIN_PATH:+:$QT_PLUGIN_PATH}"

      # QML imports
      export QML2_IMPORT_PATH="${pkgs.qt6.qtdeclarative}/${pkgs.qt6.qtbase.qtQmlPrefix}''${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}"

      # Forcer Wayland si pas déjà défini
      export QT_QPA_PLATFORM="''${QT_QPA_PLATFORM:-wayland}"

      # CMake auto-détection Qt6
      export CMAKE_PREFIX_PATH="''${CMAKE_PREFIX_PATH:-${pkgs.lib.concatStringsSep ":" [
        "${pkgs.qt6.qtbase}"
        "${pkgs.qt6.qtdeclarative}"
        "${pkgs.qt6.qtserialport}"
        "${pkgs.qt6.qtwayland}"
        "${pkgs.qt6.qtcharts}"
        "${pkgs.qt6.qtconnectivity}"
        "${pkgs.qt6.qtmultimedia}"
        "${pkgs.libGL.dev}"
      ]}}"

      # Qt6 CMake config
      export Qt6_DIR="''${Qt6_DIR:-${pkgs.qt6.qtbase}/lib/cmake/Qt6}"

      exec "${pkgs.qtcreator}/bin/qtcreator" "$@"
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    # Qt6 modules individuels
    qt6.qtbase
    qt6.qtdeclarative    # QML / Qt Quick
    qt6.qttools          # linguist, designer, uic, moc, rcc, etc.
    qt6.qtwayland        # Support Wayland natif
    qt6.qtserialport     # Communication microcontrôleurs
    qt6.qtcharts         # Graphiques
    qt6.qtconnectivity   # Bluetooth, NFC
    qt6.qtmultimedia     # Audio/Video

    # Qt Creator IDE (wrappé avec GSettings, DBus, portals)
    # Ne PAS ajouter pkgs.qtcreator directement, sinon conflit de symlinks
    qtcreator-wrapped

    # Dépendances GSettings / GTK (nécessaires pour les apps GTK/GLib)
    gsettings-desktop-schemas
    glib
    gtk3
    dconf

    # OpenGL et dépendances graphiques (requis par Qt6Gui/Qt6Quick)
    libGL
    libGL.dev
    libGLU
    xorg.libX11
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXi
    xorg.libXext
    xorg.libXrender
    xorg.libXinerama
    xorg.libxcb
    libxkbcommon
    libxkbcommon.dev
    fontconfig
    freetype
    wayland
    wayland.dev

    # Build tools
    cmake
    ninja
    gcc
    pkg-config

    # Outils de développement C++
    clang-tools  # clangd pour LSP
    lldb         # Debugger

    # Preview QML : qml (inclus dans qtdeclarative)
    # Usage : qml ui/Main.qml
  ];

  # Lier /libexec et /share pour les outils Qt6 et les schemas GSettings
  environment.pathsToLink = [ "/libexec" "/share" ];

  # Variables d'environnement pour CMake et outils Qt6
  # Note: les variables Qt Creator sont dans le wrapper ci-dessus
  environment.sessionVariables = {
    # Qt plugins et QML imports (pour les projets compilés, pas seulement Qt Creator)
    QT_PLUGIN_PATH = "${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}";
    QML2_IMPORT_PATH = "${pkgs.qt6.qtdeclarative}/${pkgs.qt6.qtbase.qtQmlPrefix}";

    # Localisation des plugins Qt pour les applications Qt6 en général
    QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}";

    # CMAKE: points d'ancrage pour trouver Qt6 automatiquement
    CMAKE_PREFIX_PATH = pkgs.lib.concatStringsSep ":" [
      "${pkgs.qt6.qtbase}"
      "${pkgs.qt6.qtdeclarative}"
      "${pkgs.qt6.qtserialport}"
      "${pkgs.qt6.qtwayland}"
      "${pkgs.qt6.qtcharts}"
      "${pkgs.qt6.qtconnectivity}"
      "${pkgs.qt6.qtmultimedia}"
      "${pkgs.libGL.dev}"
    ];

    # Chemins pour FindOpenGL.cmake et autres modules CMake
    CMAKE_INCLUDE_PATH = "${pkgs.libGL.dev}/include";
    CMAKE_LIBRARY_PATH = "${pkgs.libGL}/lib";

    # Qt6 detection: chemin vers Qt6Config.cmake et Qt6 CMake modules
    Qt6_DIR = "${pkgs.qt6.qtbase}/lib/cmake/Qt6";

    # clangd pour Neovim: includes Qt6
    CLANG_CXX_INCLUDE_PATHS = pkgs.lib.concatStringsSep ":" [
      "${pkgs.qt6.qtbase.dev}/include"
      "${pkgs.qt6.qtdeclarative.dev}/include"
      "${pkgs.libGL.dev}/include"
      "${pkgs.libxkbcommon.dev}/include"
    ];
  };
}
