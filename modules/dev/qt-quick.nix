{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Qt6 complet
    qt6.full             # Qt6 avec tous les modules
    qt6.qtbase
    qt6.qtdeclarative    # QML / Qt Quick
    qt6.qttools          # linguist, designer, uic, moc, rcc, etc.
    qt6.qtwayland        # Support Wayland natif
    qt6.qtserialport     # Communication microcontrôleurs
    qt6.qtcharts         # Graphiques
    qt6.qtconnectivity   # Bluetooth, NFC
    qt6.qtmultimedia     # Audio/Video

    # Qt Creator IDE
    qtcreator            # Qt Creator 18.0+

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
    make
    pkg-config

    # Outils de développement C++
    clang-tools  # clangd pour LSP
    lldb         # Debugger

    # Preview QML : qml (inclus dans qtdeclarative)
    # Usage : qml ui/Main.qml
  ];

  # Lier /libexec et /share pour les outils Qt6 et Qt Creator
  environment.pathsToLink = [ "/libexec" "/share" ];

  # Variables d'environnement pour Qt Creator, CMake et outils Qt6
  # Essentiel pour que Qt Creator détecte automatiquement Qt6
  environment.sessionVariables = {
    # Qt plugins et QML imports
    QT_PLUGIN_PATH = "${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}";
    QML2_IMPORT_PATH = "${pkgs.qt6.qtdeclarative}/${pkgs.qt6.qtbase.qtQmlPrefix}";

    # Qt Creator: indiquer la localisation de Qt6
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
