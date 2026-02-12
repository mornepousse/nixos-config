{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Qt Creator IDE
    qtcreator

    # Qt 5 core packages
    qt5.base
    qt5.declarative
    qt5.tools
    qt5.doc
    qt5.svg
    qt5.imageformats
    qt5.connectivity

    # Qt 6 core packages
    qt6.base
    qt6.declarative
    qt6.tools

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

    # X11 and Wayland support
    libxkbcommon
    libxcb
    xcb-util-image
    xcb-util-keysyms
    xcb-util-renderutil
    xcb-util-wm
    wayland

    # Additional libraries
    libGL
    xorg.libX11

    # Useful dev tools
    git
    wget
    curl
    htop
  ];

}
