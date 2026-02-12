{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Qt Creator IDE
    qt-creator

    # Qt libraries
    qt5.full
    qt6.full

    # Qt tools
    qt5.tools.full
    qt6.tools.full

    # Compilation tools
    gcc
    clang
    cmake
    ninja
    pkg-config
    gdb
    lldb

    # Build essentials
    binutils
    gnumake
    autoconf
    automake
    libtool

    # Additional Qt utilities
    qt5.qtbase
    qt5.qtdeclarative
    qt5.qttools
    qt6.qtbase
    qt6.qtdeclarative

    # For Qt development
    libxkbcommon
    libxcb
    xcb-util-image
    xcb-util-keysyms
    xcb-util-renderutil
    xcb-util-wm

    # Optional: useful dev tools
    gitFull
    wget
    curl
    htop
  ];

  # Environment variables for Qt
  environment.variables = {
    QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.qt5.full}/lib/qt-${pkgs.qt5.full.version}/plugins";
    LD_LIBRARY_PATH = lib.makeLibraryPath [
      pkgs.qt5.full
      pkgs.qt6.full
      pkgs.libxkbcommon
    ] + ":$LD_LIBRARY_PATH";
  };

  # Optional: Desktop entry for Qt Creator (already provided by qt-creator package)
  # But we can ensure the application menu shows it correctly

  # Qt Creator configuration symlink (optional, allows shared config across projects)
  # This creates a default Qt Creator settings directory structure

}
