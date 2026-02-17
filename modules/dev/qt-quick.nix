{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Qt6 core
    qt6.qtbase
    qt6.qtdeclarative    # QML / Qt Quick
    qt6.qttools          # linguist, designer, etc.
    qt6.qtwayland        # Support Wayland natif
    qt6.qtserialport     # Communication microcontrôleurs
    qt6.qtcharts         # Graphiques (optionnel, utile pour monitoring)

    # OpenGL (requis par Qt6Gui/Qt6Quick)
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
    fontconfig
    freetype
    wayland
    wayland.dev

    # Build tools
    cmake
    ninja
    gcc
    pkg-config

    # Debug
    gdb

    # Preview QML : qml (inclus dans qtdeclarative)
    # Usage : qml ui/Main.qml
  ];

  # Lier /libexec pour les outils Qt6 internes
  environment.pathsToLink = [ "/libexec" ];

  # Variables pour que CMake trouve Qt6 et OpenGL
  environment.sessionVariables = {
    QT_PLUGIN_PATH = "${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}";
    QML2_IMPORT_PATH = "${pkgs.qt6.qtdeclarative}/${pkgs.qt6.qtbase.qtQmlPrefix}";
    CMAKE_PREFIX_PATH = pkgs.lib.concatStringsSep ":" [
      "${pkgs.qt6.qtbase}"
      "${pkgs.qt6.qtdeclarative}"
      "${pkgs.qt6.qtserialport}"
      "${pkgs.qt6.qtwayland}"
      "${pkgs.libGL.dev}"
    ];
    # FindOpenGL.cmake a besoin de ces chemins explicites sur NixOS
    CMAKE_INCLUDE_PATH = "${pkgs.libGL.dev}/include";
    CMAKE_LIBRARY_PATH = "${pkgs.libGL}/lib";
  };
}
